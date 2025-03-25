`include "DWC_ddr_umctl2_all_includes.svh"
module ddr_wrapper (
ddr_ck_t,
ddr_ck_c,
ddr_cke,
ddr_cs_n,
ddr_odt,
ddr_act_n,
ddr_dm_n,
ddr_bg,
ddr_ba,
ddr_a,
ddr_reset_n,
ddr_dq,
ddr_dqs_t,
ddr_dqs_c,
ddr_par, // unused
ddr_alert_n, // unused
ddr_ten, // unused

system_reset,
core_ddrc_core_clk,
core_ddrc_rstn,
aresetn_0,              
aclk_0,                 
// awid_0,                 
// awaddr_0,               
// awlen_0,                
// awsize_0,               
// awburst_0,              
// awlock_0,               
// awcache_0,              
// awprot_0,               
// awuser_0,               
// awvalid_0,              
// awready_0,              
// awqos_0,                
// awregion_0,             
// wdata_0,                
// wstrb_0,                
// wlast_0,                
// wvalid_0,               
// wready_0,               
// wuser_0,                
// bid_0,                  
// bresp_0,                
// buser_0,                
// bvalid_0,               
// bready_0,               
// arid_0,                 
// araddr_0,               
// arlen_0,                
// arsize_0,               
// arburst_0,              
// arlock_0,               
// arcache_0,              
// arprot_0,               
// aruser_0,               
// arvalid_0,              
// arready_0,              
// arqos_0,                
// arregion_0,             
// rid_0,                  
// rdata_0,                
// rresp_0,                
// ruser_0,                
// rlast_0,                
// rvalid_0,               
// rready_0,               

mc_scanmode,
mc_scan_resetn,

bist_mode,
bist_mux,
bist_start,
bist_complete,
bist_error,
bscan_TDI,
bscan_TDO,
bscan_clockDR,
bscan_mode,
bscan_shiftDR,
bscan_updateDR,
ddr_plllock,
phy_scanclk,
phy_scanrstn,
phy_scanen,
phy_scanmode,
phy_scanin,
phy_scanout,
pclk,
presetn,
paddr_mc,
pwdata_mc,
pwrite_mc,
psel_mc,
penable_mc,
pready_mc,
prdata_mc,
pslverr_mc,
paddr_phy,
pwdata_phy,
pwrite_phy,
psel_phy,
penable_phy,
pready_phy,
prdata_phy,
paddr_baiyang,
pwdata_baiyang,
pwrite_baiyang,
psel_baiyang,
penable_baiyang,
pready_baiyang,
prdata_baiyang,
pslverr_baiyang,
bist_dfi_init_start,
test1a_rrb_0,
test1b_rrb_0,
rma_rrb_0,
rmb_rrb_0,
rmea_rrb_0,
rmeb_rrb_0,
test1a_wdata,
test1b_wdata,
rma_wdata,
rmb_wdata,
rmea_wdata,
rmeb_wdata,
axi_bus_rst_n,
rzq,
dft_mode,
dft_lgc_rstn,
scan_mode,
dft_glb_gt_se,
dfi_init_complete,
phy_bist_mode,
bist_dfi_frequency,
bist_bufferen_core

);
parameter NPORTS = `UMCTL2_A_NPORTS; // Number of ports   
parameter UMCTL2_WDATARAM_DW = `UMCTL2_WDATARAM_DW;
parameter UMCTL2_WDATARAM_AW = `UMCTL2_WDATARAM_AW;
parameter UMCTL2_WDATARAM_DEPTH = `UMCTL2_WDATARAM_DEPTH;
parameter UMCTL2_RDATARAM_DW = `UMCTL2_RDATARAM_DW;
parameter UMCTL2_RDATARAM_AW = `UMCTL2_RDATARAM_AW;
parameter UMCTL2_RDATARAM_DEPTH = `UMCTL2_RDATARAM_DEPTH;
parameter UMCTL2_DATARAM_PAR_DW = `UMCTL2_DATARAM_PAR_DW;
parameter UMCTL2_WDATARAM_PAR_DW = `UMCTL2_WDATARAM_PAR_DW;
parameter AXI_IDW = `UMCTL2_A_IDW; // AXI a*id width
parameter AXI_ADDRW = `UMCTL2_AXI_ADDRW; // AXI a*addr width
parameter AXI_LENW = `UMCTL2_A_LENW; // AXI a*len width
parameter AXI_USERW = `UMCTL2_AXI_USER_WIDTH_INT;
parameter OCPAR_ADDR_PARITY_WIDTH = `UMCTL2_OCPAR_ADDR_PARITY_W;
localparam AXI_SIZEW  = `UMCTL2_AXI_SIZE_WIDTH; // AXI a*size width
localparam AXI_BURSTW = `UMCTL2_AXI_BURST_WIDTH; // AXI a*burst width
localparam AXI_LOCKW  = `UMCTL2_AXI_LOCK_WIDTH; // AXI a*lock fixed width (2)
localparam AXI_CACHEW = `UMCTL2_AXI_CACHE_WIDTH; // AXI a*cache width
localparam AXI_PROTW  = `UMCTL2_AXI_PROT_WIDTH; // AXI a*prot width
localparam AXI_RESPW  = `UMCTL2_AXI_RESP_WIDTH; // AXI *resp width
localparam AXI_QOSW   = `UMCTL2_A_QOSW; // AXI a*qos width
localparam XPI_RAQD_LG2_0 = (`UMCTL2_A_TYPE_0==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_0) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_0);
localparam XPI_WAQD_LG2_0 = (`UMCTL2_A_TYPE_0==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_0) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_0);

output [1:0] ddr_ck_t   ;
output [1:0] ddr_ck_c   ;
output [1:0] ddr_cke    ;
output [1:0] ddr_cs_n   ;
output [1:0] ddr_odt    ;
output        ddr_act_n  ;
inout  [7:0] ddr_dm_n   ;
output [1:0] ddr_bg     ;
output [1:0] ddr_ba     ;
output [17:0] ddr_a      ;
output        ddr_reset_n;
inout  [63:0] ddr_dq     ;
inout  [7:0] ddr_dqs_t  ;
inout  [7:0] ddr_dqs_c  ;
output        ddr_par    ; // unused
input         ddr_alert_n; // unused
output        ddr_ten    ; // unused
input 		  core_ddrc_core_clk;
input 		  core_ddrc_rstn    ;
input         system_reset      ;
   //----------------------------------------------- 
   // AXI Interface
   //-----------------------------------------------
// AXI Port 0 Global Signals (clock, reset, low-power)
input                                aresetn_0;
input                                aclk_0;
// AXI Port 0 Write Address Channel
// input [`UMCTL2_A_IDW-1:0]            awid_0;
// input [`UMCTL2_A_ADDRW-1:0]          awaddr_0;
// input [`UMCTL2_A_LENW-1:0]           awlen_0;
// input [2:0]                          awsize_0;
// input [1:0]                          awburst_0;
// input [`UMCTL2_AXI_LOCK_WIDTH_0-1:0] awlock_0;
// input [3:0]                          awcache_0;
// input [2:0]                          awprot_0;
// input [AXI_USERW-1:0]                awuser_0;
// input                                awvalid_0;
// output                               awready_0;
// input [3:0]                          awqos_0;
// input [3:0]                          awregion_0;
// // AXI Port 0 Write Data Channel
// input [`UMCTL2_PORT_DW_0-1:0]        wdata_0;
// input [`UMCTL2_PORT_NBYTES_0-1:0]    wstrb_0;
// input                                wlast_0;
// input                                wvalid_0;
// output                               wready_0;
// input [AXI_USERW-1:0]                wuser_0;
// // AXI Port 0 Write Response Channel
// output [`UMCTL2_A_IDW-1:0]           bid_0;
// output [AXI_RESPW-1:0]               bresp_0;
// output [AXI_USERW-1:0]               buser_0;
// output                               bvalid_0;
// input                                bready_0;
// // AXI Port 0 Read Address Channel
// input [`UMCTL2_A_IDW-1:0]            arid_0;
// input [`UMCTL2_A_ADDRW-1:0]          araddr_0;
// input [`UMCTL2_A_LENW-1:0]           arlen_0;
// input [AXI_SIZEW-1:0]                arsize_0;
// input [AXI_BURSTW-1:0]               arburst_0;
// input [`UMCTL2_AXI_LOCK_WIDTH_0-1:0] arlock_0;
// input [AXI_CACHEW-1:0]               arcache_0;
// input [AXI_PROTW-1:0]                arprot_0;
// input [AXI_USERW-1:0]                aruser_0;
// input                                arvalid_0;
// output                               arready_0;
// input [AXI_QOSW-1:0]                 arqos_0;
// input [`UMCTL2_AXI_REGION_WIDTH-1:0] arregion_0;
// // AXI Port 0 Read Data Channel
// output [`UMCTL2_A_IDW-1:0]           rid_0;
// output [`UMCTL2_PORT_DW_0-1:0]       rdata_0;
// output [AXI_RESPW-1:0]               rresp_0;
// output [AXI_USERW-1:0]               ruser_0;
// output                               rlast_0;
// output                               rvalid_0;
// input                                rready_0;

input  		           				bist_bufferen_core;
output 		           				ddr_plllock  ;



input  		   						mc_scanmode   ;
input  		   						mc_scan_resetn;

input  		   						bist_mode    ;
input  		   						bist_mux     ;
input  		   						bist_start   ;
output 		   						bist_complete;
output 		   						bist_error   ;
input  		   						bscan_TDI     ;
output 		   						bscan_TDO     ;
input  		   						bscan_clockDR ;
input  		   						bscan_mode    ;
input  		   						bscan_shiftDR ;
input  		   						bscan_updateDR;
input          						phy_scanclk ;
input          						phy_scanrstn;
input          						phy_scanen  ;
input          						phy_scanmode;
input  [164:0] 						phy_scanin  ;
output [164:0] 						phy_scanout ;

input         						pclk       ;
input         						presetn    ;
input  [15:0] 						paddr_mc   ;
input  [15:0] 						paddr_phy  ;
input  [15:0] 						paddr_baiyang  ;
input  [31:0] 						pwdata_mc  ;
input  [31:0] 						pwdata_phy ;
input  [31:0] 						pwdata_baiyang ;
input         						pwrite_mc  ;
input         						pwrite_phy ;
input         						pwrite_baiyang ;
input         						psel_mc    ;
input         						psel_phy   ;
input         						psel_baiyang   ;
input         						penable_mc     ;
input         						penable_phy    ;
input         						penable_baiyang    ;
output        						pready_mc  ;
output        						pready_phy ;
output        						pready_baiyang ;
output [31:0] 						prdata_mc  ;
output [31:0] 						prdata_phy ;
output [31:0] 						prdata_baiyang ;
output        						pslverr_mc ;
output        						pslverr_baiyang ;
input         						bist_dfi_init_start;
input 		  						test1a_rrb_0;
input 		  						test1b_rrb_0;

input  [3:0]  						rma_rrb_0;
input  [3:0]  						rmb_rrb_0;

input 		  						rmea_rrb_0;
input 		  						rmeb_rrb_0;

input 		  						test1a_wdata;
input 		  						test1b_wdata;
input  [3:0]  						rma_wdata;
input  [3:0]  						rmb_wdata;
input 		  						rmea_wdata;
input 		  						rmeb_wdata;
inout                               rzq;

input                               dft_mode;
input                               dft_lgc_rstn;
input                               scan_mode;
input                               dft_glb_gt_se;
output                              dfi_init_complete;
output                              axi_bus_rst_n;
input                               phy_bist_mode;
input  [4:0]                        bist_dfi_frequency;

wire                                axi_bus_rst_n;

logic [UMCTL2_RDATARAM_DW-1:0]      rdataram_dout_0;
logic [3:0]                         rdataram_P0_0_DQ;
logic [UMCTL2_RDATARAM_DW-1:0]      rdataram_din_0;
logic                               rdataram_wr_0;
logic                               rdataram_re_0;
logic [UMCTL2_RDATARAM_AW-1:0]      rdataram_raddr_0;
logic [UMCTL2_RDATARAM_AW-1:0]      rdataram_waddr_0;
logic [UMCTL2_WDATARAM_DW-1:0]      wdataram_dout;
logic [UMCTL2_WDATARAM_DW-1:0]      wdataram_din;
logic [UMCTL2_WDATARAM_DW/8-1:0]    wdataram_mask;
logic                               wdataram_wr;
logic                               wdataram_re;
logic [UMCTL2_WDATARAM_AW-1:0]      wdataram_raddr;
logic [UMCTL2_WDATARAM_AW-1:0]      wdataram_waddr;
logic [UMCTL2_WDATARAM_DW-1:0]      wdataram_mask_bit;

logic [1:0]                                                 dfi_freq_ratio        ; // unused
logic [`UMCTL2_SHARED_AC_EN:0]                              dfi_phyupd_req        ; // unused
logic [`UMCTL2_SHARED_AC_EN:0]                              dfi_phyupd_ack        ; // unused
logic [(`UMCTL2_NUM_DATA_CHANNEL*`UMCTL2_SHARED_AC_EN)+1:0] dfi_phyupd_type       ; // unused
logic [`UMCTL2_SHARED_AC_EN:0]                              dfi_ctrlupd_ack       ; // unused
logic [`UMCTL2_SHARED_AC_EN:0]                              dfi_ctrlupd_ack2      ; // unused
logic [`UMCTL2_SHARED_AC_EN:0]                              dfi_ctrlupd_req       ; // unused
logic [`MEMC_FREQ_RATIO-1:0]                                dfi_parity_in         ; // unused
logic [`MEMC_FREQ_RATIO-1:0]                                dfi_alert_n           ; // unused
logic                                                       dfi_geardown_en       ; // unused
logic                                                       dfi_alert_err_intr    ; // unused
logic                                                       ctl_idle              ; // unused
logic [ (`MEMC_FREQ_RATIO*`MEMC_DFI_ADDR_WIDTH)-1:0] mc_dfi_address    ;                                      
logic [ `MEMC_FREQ_RATIO-1:0]                        dfi_act_n         ;               
logic [ (`MEMC_FREQ_RATIO*`MEMC_BANK_BITS)-1:0]      dfi_bank          ;                                 
logic [ (`MEMC_FREQ_RATIO*`MEMC_BG_BITS)-1:0]        dfi_bg            ;                               
logic [ `MEMC_FREQ_RATIO-1:0]                        dfi_cas_n         ;               
logic [ `MEMC_FREQ_RATIO-1:0]                        dfi_ras_n         ;               
logic [ `MEMC_FREQ_RATIO-1:0]                        dfi_we_n          ;               
logic [ (`MEMC_FREQ_RATIO*`MEMC_NUM_RANKS)-1:0]      mc_dfi_cke        ;                                 
logic [ (`MEMC_FREQ_RATIO*`MEMC_NUM_RANKS)-1:0]      mc_dfi_cs_n       ;                                                                     
logic [ (`MEMC_FREQ_RATIO*`MEMC_NUM_RANKS)-1:0]      mc_dfi_odt        ;                                 
logic [ (`MEMC_FREQ_RATIO*`UMCTL2_RESET_WIDTH)-1:0]  dfi_reset_n       ;                                     
logic [ `MEMC_DFI_TOTAL_DATA_WIDTH -1:0]             dfi_wrdata        ;                          
logic [ `MEMC_DFI_TOTAL_MASK_WIDTH -1:0]             dfi_wrdata_mask   ;                          
logic [ `MEMC_DFI_TOTAL_DATAEN_WIDTH -1:0]           mc_dfi_wrdata_en  ;                            
logic [ `MEMC_DFI_TOTAL_DATA_WIDTH -1:0]             dfi_rddata        ;                          
logic [ `MEMC_DFI_TOTAL_DATAEN_WIDTH -1:0]           mc_dfi_rddata_en  ;                            
logic [  7:0]                                        dfi_rddata_valid  ;
logic [ `MEMC_DFI_TOTAL_DATA_WIDTH/8-1:0]            dfi_rddata_dbi    ;  

logic [ (`MEMC_FREQ_RATIO*`MEMC_DFI_ADDR_WIDTH)-1:0] DWC_mc_dfi_address    ;
logic [ `MEMC_FREQ_RATIO-1:0]                        DWC_dfi_act_n     ;
logic [ (`MEMC_FREQ_RATIO*`MEMC_BANK_BITS)-1:0]      DWC_dfi_bank      ;                                 
logic [ (`MEMC_FREQ_RATIO*`MEMC_BG_BITS)-1:0]        DWC_dfi_bg        ; 
logic [ (`MEMC_FREQ_RATIO*`MEMC_NUM_RANKS)-1:0]      DWC_mc_dfi_cke    ;                                 
logic [ (`MEMC_FREQ_RATIO*`MEMC_NUM_RANKS)-1:0]      DWC_mc_dfi_cs_n   ;                                                                     
logic [ (`MEMC_FREQ_RATIO*`MEMC_NUM_RANKS)-1:0]      DWC_mc_dfi_odt    ; 
logic [ `MEMC_DFI_TOTAL_DATA_WIDTH -1:0]             DWC_dfi_wrdata        ;                          
logic [ `MEMC_DFI_TOTAL_MASK_WIDTH -1:0]             DWC_dfi_wrdata_mask   ;                          
logic [ `MEMC_DFI_TOTAL_DATAEN_WIDTH -1:0]           DWC_mc_dfi_wrdata_en  ;
logic [ `MEMC_DFI_TOTAL_DATAEN_WIDTH -1:0]           DWC_mc_dfi_rddata_en  ;

wire           wire_io_as2scg_cmdRdy   ; 
wire           wire_io_as2scg_cmdValid ; 
wire           wire_io_as2scgcmd_bits_adr_cmdtype      ; 
wire  	       wire_io_as2scgcmd_bits_adr_adr_rank     ; 
wire  [1:0]    wire_io_as2scgcmd_bits_adr_adr_group      ; 
wire  [1:0]    wire_io_as2scgcmd_bits_adr_adr_bank    ; 
wire  [17:0]   wire_io_as2scgcmd_bits_adr_adr_row     ; 
wire  [9:0]    wire_io_as2scgcmd_bits_adr_adr_col      ; 
wire  [16:0]   wire_io_as2scgcmd_bits_adr_adr_cmdtoken    ; 
wire           wire_io_as2scgcmd_priority ; 
wire  [511:0]  wire_io_as2scg_wrData   ; 
wire  [64:0]   wire_io_as2scg_dataMask ;   

wire  [35:0]   io_dfi_dfictrl_dfi_address ;
wire  [3:0]    io_dfi_dfictrl_dfi_bank    ;
wire  [1:0]    io_dfi_dfictrl_dfi_ras_n   ;    
wire  [1:0]    io_dfi_dfictrl_dfi_cas_n   ;
wire  [1:0]    io_dfi_dfictrl_dfi_we_n    ;
wire  [1:0]    io_dfi_dfictrl_dfi_cs_n    ;
wire  [1:0]    io_dfi_dfictrl_dfi_act_n   ;
wire  [3:0]    io_dfi_dfictrl_dfi_bg     ;
wire  [1:0]    io_dfi_dfictrl_dfi_cke    ;
wire  [1:0]    io_dfi_dfictrl_dfi_odt    ;
wire  [1:0]    io_dfi_dfictrl_dfi_reset_n;
wire  [15:0]   io_dfi_dfiwrdata_dfi_wrdata_en ;
wire  [255:0]  io_dfi_dfiwrdata_dfi_wdata   ;
wire  [31:0]  io_dfi_dfiwrdata_dfi_wdata_cs_n ;
wire  [31:0]  io_dfi_dfiwrdata_dfi_wdata_mask ;
wire  [15:0]  io_dfi_dfirddata_dfi_rddata_en ;
wire  [31:0]  io_dfi_dfirddata_dfi_rddata_cs_n ;
wire		  io_dfi_dfiupdate_dfi_ctrlupd_req	;
wire		  io_dfi_dfiupdate_dfi_ctrlupd_ack	;
wire		  io_dfi_dfiupdate_dfi_phyupd_req	;
wire		  io_dfi_dfiupdate_dfi_phyupd_type	;
wire		  io_dfi_dfiupdate_dfi_phyupd_ack	;
wire		  io_dfi_dfistatus_dfi_data_byte_disable;
wire		  io_dfi_dfistatus_dfi_dram_clk_disable	;
wire		  io_dfi_dfistatus_dfi_freq_ratio		;
wire		  io_dfi_dfistatus_dfi_init_start		;
wire		  io_dfi_dfilp_dfi_lp_ctrl_req			;
wire		  io_dfi_dfilp_dfi_lp_wakeup			;		  
// wire		  io_dfi_dfistatus_dfi_init_complete	;




logic [ (`MEMC_NUM_CLKS<<`UMCTL2_SHARED_AC_EN)-1:0]            dfi_dram_clk_disable     ;
logic                                                          dfi_init_complete        ;
logic                                                          dfi_init_start           ;
logic [  4:0]                                                  dfi_frequency            ;
logic [ `UMCTL2_SHARED_AC_EN:0]                                dfi_lp_req               ;
logic [ `UMCTL2_SHARED_AC_EN:0]                                dfi_lp_ack               ;
logic [ (`UMCTL2_NUM_DATA_CHANNEL*`UMCTL2_SHARED_AC_EN*2)+3:0] dfi_lp_wakeup            ;
logic                                                          dfi_phymstr_req          ;
logic                                                          dfi_phymstr_ack          ;
logic [ `MEMC_NUM_RANKS-1:0]                                   dfi_phymstr_cs_state     ;
logic                                                          dfi_phymstr_state_sel    ;
logic [1:0]                                                    dfi_phymstr_type         ;
logic [ `UMCTL2_APB_DW-1:0]                                    mc_prdata                ;
logic                                                          phy_bufferen_core        ;
logic [1:0]                                                    phy_dfi_act_n            ;
logic [ 39:0]                                                  phy_dfi_address          ;
logic [ (`MEMC_FREQ_RATIO*`MEMC_BANK_BITS)-1:0]                phy_dfi_bank             ;
logic [ (`MEMC_FREQ_RATIO*`MEMC_BG_BITS)-1:0]                  phy_dfi_bg               ;
logic [ `MEMC_FREQ_RATIO-1:0]                                  phy_dfi_ras_n            ;
logic [ `MEMC_FREQ_RATIO-1:0]                                  phy_dfi_cas_n            ;
logic [ `MEMC_FREQ_RATIO-1:0]                                  phy_dfi_we_n             ;
logic [ (`MEMC_FREQ_RATIO*`MEMC_NUM_RANKS)-1:0]                phy_dfi_cke              ;
logic [ (`MEMC_FREQ_RATIO*`MEMC_NUM_RANKS)-1:0]                phy_dfi_cs_n             ;
logic [ (`MEMC_FREQ_RATIO*`MEMC_NUM_RANKS)-1:0]                phy_dfi_odt              ;
logic [ 1:0]                                                   phy_dfi_reset_n          ;
logic [ `MEMC_DFI_TOTAL_DATA_WIDTH -1:0]                       phy_dfi_wrdata           ;
logic [ `MEMC_DFI_TOTAL_DATAEN_WIDTH -1:0]                     phy_dfi_wrdata_en        ;
logic [ `MEMC_DFI_TOTAL_MASK_WIDTH -1:0]                       phy_dfi_wrdata_mask      ;
logic [ `MEMC_DFI_TOTAL_DATAEN_WIDTH -1:0]                     phy_dfi_rddata_en        ;
logic [ (`MEMC_NUM_CLKS<<`UMCTL2_SHARED_AC_EN)-1:0]            phy_dfi_dram_clk_disable ;
logic [ 4:0]                                                   phy_dfi_frequency        ;
logic                                                          phy_dfi_init_start       ;
logic [ `UMCTL2_SHARED_AC_EN:0]                                phy_dfi_lp_req           ;
logic [ (`UMCTL2_NUM_DATA_CHANNEL*`UMCTL2_SHARED_AC_EN*2)+3:0] phy_dfi_lp_wakeup        ;

logic                               awpoison_intr_0                              ;
logic                               arpoison_intr_0                              ;
logic [XPI_RAQD_LG2_0:0]            raq_wcount_0                                 ;
logic                               raq_pop_0                                    ;
logic                               raq_push_0                                   ;
logic                               raq_split_0                                  ;
logic [XPI_WAQD_LG2_0:0]            waq_wcount_0                                 ;
logic                               waq_pop_0                                    ;
logic                               waq_push_0                                   ;
logic                               waq_split_0                                  ;
logic                               csysreq_0                                    ;
logic                               csysack_0                                    ;
logic                               cactive_0                                    ;
logic		           				csysreq_ddrc                                 ;
logic		           				csysack_ddrc                                 ;
logic		           				cactive_ddrc                                 ;
logic [1:0]           				stat_ddrc_reg_selfref_type                   ;
logic [6:0] 						lpr_credit_cnt                               ;
logic [6:0] 						hpr_credit_cnt                               ;
logic [6:0] 						wr_credit_cnt                                ;
logic [`MEMC_MRR_DATA_TOTAL_DATA_WIDTH-1:0] 						hif_mrr_data ;
logic 								hif_mrr_data_valid                           ;
logic                               init_rstn_mc                                 ;
logic                               o_presetn                                    ;
logic                               o_core_ddrc_rstn                             ;
logic                               o_aresetn_0                                  ;
logic                               phy_bist_mode                                ;
logic                               bist_bufferen_core                           ;
logic [  4:0]                       bist_dfi_frequency                           ;

generate
	genvar i,j;
	for (i = 0; i < (UMCTL2_WDATARAM_DW/8); i=(i+1)) begin:wdataram_mask_bit_init
		assign wdataram_mask_bit[i*8+0] = wdataram_mask[i];
		assign wdataram_mask_bit[i*8+1] = wdataram_mask[i];
		assign wdataram_mask_bit[i*8+2] = wdataram_mask[i];
		assign wdataram_mask_bit[i*8+3] = wdataram_mask[i];
		assign wdataram_mask_bit[i*8+4] = wdataram_mask[i];
		assign wdataram_mask_bit[i*8+5] = wdataram_mask[i];
		assign wdataram_mask_bit[i*8+6] = wdataram_mask[i];
		assign wdataram_mask_bit[i*8+7] = wdataram_mask[i];
	end
endgenerate
assign ddr_par           = 1'b0; // unused
assign ddr_ten           = 1'b0; // unused
assign dfi_phymstr_type      = 2'b00;
assign dfi_phymstr_req       = 1'b0;
assign dfi_phymstr_state_sel = 1'b0;
assign dfi_phymstr_cs_state  = 2'b00;



assign phy_bufferen_core        =  phy_bist_mode  ? bist_bufferen_core  : 1'b1                                                        ;
assign phy_dfi_act_n            =  phy_bist_mode  ? 2'b00               : dfi_act_n                                                   ;
assign phy_dfi_address          =  phy_bist_mode  ? {40{1'b0}}          : {2'b00, mc_dfi_address[35:18], 2'b00, mc_dfi_address[17:0]} ;
assign phy_dfi_bank             =  phy_bist_mode  ? {6{1'b0}}           : dfi_bank                                         	          ;
assign phy_dfi_bg               =  phy_bist_mode  ? {4{1'b0}}           : dfi_bg                                                      ;
assign phy_dfi_ras_n            =  phy_bist_mode  ? 2'b00               : 2'h3                                                        ;
assign phy_dfi_cas_n            =  phy_bist_mode  ? 2'b00               : 2'h3                                                        ;
assign phy_dfi_we_n             =  phy_bist_mode  ? 2'b00               : 2'h3                                                        ;
assign phy_dfi_cke              =  phy_bist_mode  ? {4{1'b0}}           : mc_dfi_cke                                                  ;
assign phy_dfi_cs_n             =  phy_bist_mode  ? {4{1'b0}}           : mc_dfi_cs_n                                                 ;
assign phy_dfi_odt              =  phy_bist_mode  ? {4{1'b0}}           : mc_dfi_odt                                                  ;
assign phy_dfi_reset_n          =  phy_bist_mode  ? 2'b00               : dfi_reset_n                             						;
assign phy_dfi_wrdata           =  phy_bist_mode  ? {256{1'b0}}         : dfi_wrdata                                                  	;
assign phy_dfi_wrdata_en        =  phy_bist_mode  ? {16{1'b0}}          : mc_dfi_wrdata_en                                            	;
assign phy_dfi_wrdata_mask      =  phy_bist_mode  ? {32{1'b0}}          : dfi_wrdata_mask                                             ;
assign phy_dfi_rddata_en        =  phy_bist_mode  ? {16{1'b0}}          : mc_dfi_rddata_en                                            ;
assign phy_dfi_dram_clk_disable =  phy_bist_mode  ? 1'b0                : dfi_dram_clk_disable                                        ;
assign phy_dfi_frequency        =  phy_bist_mode  ? bist_dfi_frequency  : dfi_frequency                                               ;
assign phy_dfi_init_start       =  phy_bist_mode  ? bist_dfi_init_start : dfi_init_start                                              ;     
assign phy_dfi_lp_req           =  phy_bist_mode  ? 1'b0                : dfi_lp_req                                                  ;
assign phy_dfi_lp_wakeup        =  phy_bist_mode  ? {4{1'b0}}           : dfi_lp_wakeup                                               ;

assign rdataram_dout_0[UMCTL2_RDATARAM_DW-1] = rdataram_P0_0_DQ[0];

assign dfi_alert_n        = 2'b11;
assign dfi_phyupd_req     = 1'b0;
assign dfi_ctrlupd_ack    = 1'b0;
assign dfi_phyupd_type    = 2'b00;

always_ff @(posedge pclk or negedge presetn) begin
    if(~presetn) begin
        init_rstn_mc <= 1'b0;
    end else if ((paddr_mc == 16'hffff) && psel_baiyang && ~pwrite_baiyang && pready_baiyang) begin
        init_rstn_mc <= 1'b1;
    end
end

state_Counter stateCounter ();
ddr_crg ddr_crg_i (
.dft_mode                           (dft_mode           ),
.dft_lgc_rstn                       (dft_lgc_rstn       ),
.scan_mode                          (scan_mode          ),
.dft_glb_gt_se                      (dft_glb_gt_se      ),
.core_ddrc_core_clk                 (core_ddrc_core_clk ),
.core_ddrc_rstn                     (core_ddrc_rstn     ),
.aclk_0                             (aclk_0             ),
.aresetn_0                          (aresetn_0          ),
.pclk                               (pclk               ),
.presetn                            (presetn            ),
.init_rstn_mc                       (init_rstn_mc       ),
.o_core_ddrc_rstn                   (o_core_ddrc_rstn   ),    
.o_aresetn_0                        (o_aresetn_0        ),    
.axi_bus_rst_n                      (axi_bus_rst_n      ),    
.o_presetn                          (o_presetn          ) );

//-------------------------external ram--------------------------------
 //----------------------------------------------- 
 // Read Reorder Buffer (RRB) External Data RAM Interface - Port 0
 //-----------------------------------------------
 sram_dp_128x4 rdataram_P0_0
 (  .QB                          (rdataram_P0_0_DQ),
    .ADRA                        (rdataram_waddr_0),
    .DA                          ({3'b0,rdataram_din_0[UMCTL2_RDATARAM_DW-1]}),
    .WEA                         (rdataram_wr_0),
    .MEA                         (rdataram_wr_0),
    .CLKA                        (core_ddrc_core_clk),
    .TEST1A                      (test1a_rrb_0),
    .RMEA                        (rmea_rrb_0),
    .RMA                         (rma_rrb_0),
    .ADRB                        (rdataram_raddr_0),
    .MEB                         (rdataram_re_0),
    .CLKB                        (core_ddrc_core_clk),
    .TEST1B                      (test1b_rrb_0),
    .RMEB                        (rmeb_rrb_0),
    .RMB                         (rmb_rrb_0));
sram_dp_128x256 rdataram_P0_1
(   .QB                          (rdataram_dout_0[UMCTL2_RDATARAM_DW-2:0]),
    .ADRA                        (rdataram_waddr_0),
    .DA                          (rdataram_din_0[UMCTL2_RDATARAM_DW-2:0]),
    .WEA                         (rdataram_wr_0),
    .MEA                         (rdataram_wr_0),
    .CLKA                        (core_ddrc_core_clk),
    .TEST1A                      (test1a_rrb_0),
    .RMEA                        (rmea_rrb_0),
    .RMA                         (rma_rrb_0),
    .ADRB                        (rdataram_raddr_0),
    .MEB                         (rdataram_re_0),
    .CLKB                        (core_ddrc_core_clk),
    .TEST1B                      (test1b_rrb_0),
    .RMEB                        (rmeb_rrb_0),
    .RMB                         (rmb_rrb_0));
sram_dp_128x256_m wdataram_0
( 
	.QB                          (wdataram_dout),
 	.ADRA                        (wdataram_waddr),
 	.DA                          (wdataram_din),
 	.WEMA                        (wdataram_mask_bit),
 	.WEA                         (wdataram_wr),
 	.MEA                         (wdataram_wr),
 	.CLKA                        (core_ddrc_core_clk),
 	.TEST1A                      (test1a_wdata),
 	.RMEA                        (rmea_wdata),
 	.RMA                         (rma_wdata),
 	.ADRB                        (wdataram_raddr),
 	.MEB                         (wdataram_re),
 	.CLKB                        (core_ddrc_core_clk),
 	.TEST1B                      (test1b_wdata),
 	.RMEB                        (rmeb_wdata),
 	.RMB                         (rmb_wdata));

inno_ddr_phy i_inno_ddr_phy (
	.dfi_clk1x_in        (core_ddrc_core_clk                                                     ),     
	.system_rstn         (o_core_ddrc_rstn                                                       ),     
	.bist_mode           (bist_mode                                                              ),     
	.bist_mux            (bist_mux                                                               ),     
	.bist_start          (bist_start                                                             ),     
	.bist_complete       (bist_complete                                                          ),     
	.bist_error          (bist_error                                                             ),     
	.bscan_clockDR       (bscan_clockDR                                                          ),     
	.bscan_mode          (bscan_mode                                                             ),     
	.bscan_TDI           (bscan_TDI                                                              ),     
	.bscan_TDO           (bscan_TDO                                                              ),     
	.bscan_shiftDR       (bscan_shiftDR                                                          ),     
	.bscan_updateDR      (bscan_updateDR                                                         ),     
	.bufferen_core       (phy_bufferen_core                                                      ),
	.ddr_plllock         (ddr_plllock                                                            ),    
	.dfi_act_n           (phy_dfi_act_n                                                          ),
	.dfi_address         (phy_dfi_address                                                        ),
	.dfi_bank            (phy_dfi_bank                                                           ),
	.dfi_bg              (phy_dfi_bg                                                             ),
	.dfi_ras_n           (phy_dfi_ras_n                                                          ),
	.dfi_cas_n           (phy_dfi_cas_n                                                          ),
	.dfi_we_n            (phy_dfi_we_n                                                           ),
	.dfi_cke             (phy_dfi_cke                                                            ),
	.dfi_cs_n            (phy_dfi_cs_n                                                           ),
	.dfi_odt             (phy_dfi_odt                                                            ),
	.dfi_reset_n         (phy_dfi_reset_n                                                        ),
	.dfi_wrdata          (phy_dfi_wrdata                                                         ),
	.dfi_wrdata_en       (phy_dfi_wrdata_en                                                      ),
	.dfi_wrdata_mask     (phy_dfi_wrdata_mask                                                    ),
	.dfi_rddata          (dfi_rddata                                                             ),    
	.dfi_rddata_en       (phy_dfi_rddata_en                                                      ),
	.dfi_rddata_dbi      (dfi_rddata_dbi                                                         ),    
	.dfi_rddata_valid    (dfi_rddata_valid                                                       ),    
	.dfi_dram_clk_disable(phy_dfi_dram_clk_disable 				                                 ),//phy_dfi_dram_clk_disable 
	.dfi_frequency       (phy_dfi_frequency                                        				 ),//phy_dfi_frequency
	.dfi_init_start      (phy_dfi_init_start	                                                 ),//phy_dfi_init_start     
	.dfi_init_complete   (dfi_init_complete              	                     				 ),         
	.dfi_phymstr_req     (                                                                       ),//       ignore 
	.dfi_phymstr_ack     (1'b0                                                                   ),//       ignore 
	.dfi_lp_req          (phy_dfi_lp_req                                                         ),
	.dfi_lp_ack          (dfi_lp_ack                                                             ),         
	.dfi_lp_wakeup       (phy_dfi_lp_wakeup                                                      ),
	.pclk                (pclk                                                                   ),
	.presetn             (o_presetn                                                              ),
	.psel                (psel_phy                                                               ),
	.paddr               (paddr_phy[12:0]                                                        ),
	.penable             (penable_phy                                                            ),
	.pwrite              (pwrite_phy                                                             ),
	.pwdata              (pwdata_phy                                                             ),
	.prdata              (prdata_phy                                                             ),
	.pready              (pready_phy                                                             ),
	.scanclk             (phy_scanclk                                                            ),
	.scanrstn            (phy_scanrstn                                                           ),
	.scanen              (phy_scanen                                                             ),
	.scanmode            (phy_scanmode                                                           ),
	.scanin              (phy_scanin                                                             ),
	.scanout             (phy_scanout                                                            ),
	.A0                  (ddr_a[0 ]                                                              ),
	.A1                  (ddr_a[1 ]                                                              ),
	.A2                  (ddr_a[2 ]                                                              ),
	.A3                  (ddr_a[3 ]                                                              ),
	.A4                  (ddr_a[4 ]                                                              ),
	.A5                  (ddr_a[5 ]                                                              ),
	.A6                  (ddr_a[6 ]                                                              ),
	.A7                  (ddr_a[7 ]                                                              ),
	.A8                  (ddr_a[8 ]                                                              ),
	.A9                  (ddr_a[9 ]                                                              ),
	.A10                 (ddr_a[10]                                                              ),
	.A11                 (ddr_a[11]                                                              ),
	.A12                 (ddr_a[12]                                                              ),
	.A13                 (ddr_a[13]                                                              ),
	.A14                 (ddr_a[14]                                                              ),
	.A15                 (ddr_a[15]                                                              ),
	.A16                 (ddr_a[16]                                                              ),
	.A17                 (ddr_a[17]                                                              ),
	.ACTN                (ddr_act_n                                                              ),
	.BA0                 (ddr_ba[0]                                                              ),
	.BA1                 (ddr_ba[1]                                                              ),
	.BG0                 (ddr_bg[0]                                                              ),
	.BG1                 (ddr_bg[1]                                                              ),
	.CK0                 (ddr_ck_t[0]                                                            ),
	.CKB0                (ddr_ck_c[0]                                                            ),
	.CK1                 (ddr_ck_t[1]                                                            ),
	.CKB1                (ddr_ck_c[1]                                                            ),
	.CKE0                (ddr_cke[0]                                                             ),
	.CKE1                (ddr_cke[1]                                                             ),
	.CSB0                (ddr_cs_n[0]                                                            ),
	.CSB1                (ddr_cs_n[1]                                                            ),
	.ODT0                (ddr_odt[0]                                                             ),
	.ODT1                (ddr_odt[1]                                                             ),
	.RESETN              (ddr_reset_n                                                            ),
	.A_DM0               (ddr_dm_n[0]                                                            ),
	.A_DM1               (ddr_dm_n[1]                                                            ),
	.A_DQ0               (ddr_dq[0 ]                                                             ),
	.A_DQ1               (ddr_dq[1 ]                                                             ),
	.A_DQ2               (ddr_dq[2 ]                                                             ),
	.A_DQ3               (ddr_dq[3 ]                                                             ),
	.A_DQ4               (ddr_dq[4 ]                                                             ),
	.A_DQ5               (ddr_dq[5 ]                                                             ),
	.A_DQ6               (ddr_dq[6 ]                                                             ),
	.A_DQ7               (ddr_dq[7 ]                                                             ),
	.A_DQ8               (ddr_dq[8 ]                                                             ),
	.A_DQ9               (ddr_dq[9 ]                                                             ),
	.A_DQ10              (ddr_dq[10]                                                             ),
	.A_DQ11              (ddr_dq[11]                                                             ),
	.A_DQ12              (ddr_dq[12]                                                             ),
	.A_DQ13              (ddr_dq[13]                                                             ),
	.A_DQ14              (ddr_dq[14]                                                             ),
	.A_DQ15              (ddr_dq[15]                                                             ),
	.A_DQS0              (ddr_dqs_t[0]                                                           ),
	.A_DQS1              (ddr_dqs_t[1]                                                           ),
	.A_DQSB0             (ddr_dqs_c[0]                                                           ),
	.A_DQSB1             (ddr_dqs_c[1]                                                           ),
	.B_DM0               (ddr_dm_n[2]                                                            ),
	.B_DM1               (ddr_dm_n[3]                                                            ),
	.B_DQ0               (ddr_dq[16]                                                             ),
	.B_DQ1               (ddr_dq[17]                                                             ),
	.B_DQ2               (ddr_dq[18]                                                             ),
	.B_DQ3               (ddr_dq[19]                                                             ),
	.B_DQ4               (ddr_dq[20]                                                             ),
	.B_DQ5               (ddr_dq[21]                                                             ),
	.B_DQ6               (ddr_dq[22]                                                             ),
	.B_DQ7               (ddr_dq[23]                                                             ),
	.B_DQ8               (ddr_dq[24]                                                             ),
	.B_DQ9               (ddr_dq[25]                                                             ),
	.B_DQ10              (ddr_dq[26]                                                             ),
	.B_DQ11              (ddr_dq[27]                                                             ),
	.B_DQ12              (ddr_dq[28]                                                             ),
	.B_DQ13              (ddr_dq[29]                                                             ),
	.B_DQ14              (ddr_dq[30]                                                             ),
	.B_DQ15              (ddr_dq[31]                                                             ),
	.B_DQS0              (ddr_dqs_t[2]                                                           ),
	.B_DQS1              (ddr_dqs_t[3]                                                           ),
	.B_DQSB0             (ddr_dqs_c[2]                                                           ),
	.B_DQSB1             (ddr_dqs_c[3]                                                           ),
	.C_DM0               (ddr_dm_n[4]                                                            ),
	.C_DM1               (ddr_dm_n[5]                                                            ),
	.C_DQ0               (ddr_dq[32]                                                             ),
	.C_DQ1               (ddr_dq[33]                                                             ),
	.C_DQ2               (ddr_dq[34]                                                             ),
	.C_DQ3               (ddr_dq[35]                                                             ),
	.C_DQ4               (ddr_dq[36]                                                             ),
	.C_DQ5               (ddr_dq[37]                                                             ),
	.C_DQ6               (ddr_dq[38]                                                             ),
	.C_DQ7               (ddr_dq[39]                                                             ),
	.C_DQ8               (ddr_dq[40]                                                             ),
	.C_DQ9               (ddr_dq[41]                                                             ),
	.C_DQ10              (ddr_dq[42]                                                             ),
	.C_DQ11              (ddr_dq[43]                                                             ),
	.C_DQ12              (ddr_dq[44]                                                             ),
	.C_DQ13              (ddr_dq[45]                                                             ),
	.C_DQ14              (ddr_dq[46]                                                             ),
	.C_DQ15              (ddr_dq[47]                                                             ),
	.C_DQS0              (ddr_dqs_t[4]                                                           ),
	.C_DQS1              (ddr_dqs_t[5]                                                           ),
	.C_DQSB0             (ddr_dqs_c[4]                                                           ),
	.C_DQSB1             (ddr_dqs_c[5]                                                           ),
	.D_DM0               (ddr_dm_n[6]                                                            ),
	.D_DM1               (ddr_dm_n[7]                                                            ),
	.D_DQ0               (ddr_dq[48]                                                             ),
	.D_DQ1               (ddr_dq[49]                                                             ),
	.D_DQ2               (ddr_dq[50]                                                             ),
	.D_DQ3               (ddr_dq[51]                                                             ),
	.D_DQ4               (ddr_dq[52]                                                             ),
	.D_DQ5               (ddr_dq[53]                                                             ),
	.D_DQ6               (ddr_dq[54]                                                             ),
	.D_DQ7               (ddr_dq[55]                                                             ),
	.D_DQ8               (ddr_dq[56]                                                             ),
	.D_DQ9               (ddr_dq[57]                                                             ),
	.D_DQ10              (ddr_dq[58]                                                             ),
	.D_DQ11              (ddr_dq[59]                                                             ),
	.D_DQ12              (ddr_dq[60]                                                             ),
	.D_DQ13              (ddr_dq[61]                                                             ),
	.D_DQ14              (ddr_dq[62]                                                             ),
	.D_DQ15              (ddr_dq[63]                                                             ),
	.D_DQS0              (ddr_dqs_t[6]                                                           ),
	.D_DQS1              (ddr_dqs_t[7]                                                           ),
	.D_DQSB0             (ddr_dqs_c[6]                                                           ),
	.D_DQSB1             (ddr_dqs_c[7]                                                           ),
	.PLLVCCA             (                                                                       ),
	.RZQ                 (rzq                                                                    ),
	.VDD                 (                                                                       ),
	.VDDQ                (                                                                       ),
	.VSS                 (                                                                       ),
	.VSSA                (                                                                       ),
	.VSSQ                (                                                                       )
);

reg    training_done;
//assign  training_done = awvalid_0;
always@(posedge core_ddrc_core_clk) begin
   if (!core_ddrc_rstn)
      training_done <= 1'b0;
   else if (training_done)
      training_done <= 1'b1;
   else if (paddr_baiyang[15:0] == 'hfffb &&psel_baiyang && penable_baiyang)
      training_done <= 1'b1;
   else
      training_done <= 1'b0;
end


wire            io_cmdOut_valid             ; 
wire            io_cmdOut_bits_rank         ; 
wire    [1:0]   io_cmdOut_bits_bg           ; 
wire    [1:0]   io_cmdOut_bits_bank         ; 
wire    [14:0]  io_cmdOut_bits_row          ; 
wire    [9:0]   io_cmdOut_bits_col          ; 
wire            io_cmdOut_bits_pri          ; 
wire    [9:0]   io_cmdOut_bits_token        ;     
wire    [511:0] io_cmdOut_bits_data         ; 
wire    [63:0]  io_cmdOut_bits_wStrb         ; 
wire            io_cmdOut_bits_isRd         ; 
wire            io_dataFromScg_ready        ;    
wire            io_dataFromScg_valid        ;
wire    [10:0]  io_dataFromScg_bits_token   ;    
wire    [511:0] io_dataFromScg_bits_data    ;           
wire   	        io_calDone				  ;
assign 			io_calDone = 1'b1;

// mc_top u_mc_top(
// .io_clk					   (core_ddrc_core_clk    ),
// .io_rst					   (system_reset /*!core_ddrc_rstn*/       ),
// .io_awio_awid              (axiawio.awid      ),     
// .io_awio_awaddr            (axiawio.awaddr    ),     
// .io_awio_awlen             (axiawio.awlen     ),     
// .io_awio_awsize            (axiawio.awsize    ),     
// .io_awio_awburst           (axiawio.awburst   ),             
// .io_awio_awuser            (axiawio.awuser    ),     
// .io_awio_awqos             (axiawio.awqos     ),     
// .io_awio_awvalid           (axiawio.awvalid   ),                  
// .io_awio_awready           (axiawio.awready   ),         
// .io_wio_wid                (axiwio.wid        ), 
// .io_wio_wuser              (axiwio.wuser      ),     
// .io_wio_wdata              (axiwio.wdata      ),         
// .io_wio_wstrb              (axiwio.wstrb      ),     
// .io_wio_wlast              (axiwio.wlast      ),     
// .io_wio_wvalid             (axiwio.wvalid     ),     
// .io_wio_wready             (axiwio.wready     ),     
// .io_bio_bid                (axibio.bid        ), 
// .io_bio_bresp              (axibio.bresp      ),     
// .io_bio_buser              (axibio.buser      ),     
// .io_bio_bvalid             (axibio.bvalid     ),     
// .io_bio_bready             (axibio.bready     ),     
// .io_ario_arid              (axiario.arid      ),     
// .io_ario_araddr            (axiario.araddr    ),     
// .io_ario_arlen             (axiario.arlen     ),     
// .io_ario_arsize            (axiario.arsize    ),     
// .io_ario_arburst           (axiario.arburst   ),             
// .io_ario_aruser            (axiario.aruser    ),     
// .io_ario_arqos             (axiario.arqos     ),             
// .io_ario_arvalid           (axiario.arvalid   ),         
// .io_ario_arready           (axiario.arready   ),         
// .io_rio_rid                (axirio.rid        ), 
// .io_rio_ruser              (axirio.ruser      ),     
// .io_rio_rdata              (axirio.rdata      ),        
// .io_rio_rresp              (axirio.rresp      ),     
// .io_rio_rlast              (axirio.rlast      ),     
// .io_rio_rvalid             (axirio.rvalid     ),     
// .io_rio_rready             (axirio.rready     ),  
// .io_calDone				   (io_calDone        ),
// .io_dfi_dfictrl_dfi_address                     (io_dfi_dfictrl_dfi_address)  ,
// .io_dfi_dfictrl_dfi_bank                        (io_dfi_dfictrl_dfi_bank )    ,
// .io_dfi_dfictrl_dfi_ras_n                       (io_dfi_dfictrl_dfi_ras_n)    ,
// .io_dfi_dfictrl_dfi_cas_n                       (io_dfi_dfictrl_dfi_cas_n)    ,
// .io_dfi_dfictrl_dfi_we_n                        (io_dfi_dfictrl_dfi_we_n )    ,
// .io_dfi_dfictrl_dfi_cs_n                        (io_dfi_dfictrl_dfi_cs_n )    ,
// .io_dfi_dfictrl_dfi_act_n                       (io_dfi_dfictrl_dfi_act_n)    ,
// .io_dfi_dfictrl_dfi_bg                          (io_dfi_dfictrl_dfi_bg)    ,	
// .io_dfi_dfictrl_dfi_cid                         ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
// .io_dfi_dfictrl_dfi_cke                         (io_dfi_dfictrl_dfi_cke)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
// .io_dfi_dfictrl_dfi_odt                         (io_dfi_dfictrl_dfi_odt)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
// .io_dfi_dfictrl_dfi_reset_n                     (io_dfi_dfictrl_dfi_reset_n)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
// .io_dfi_dfiwrdata_dfi_wrdata_en                 (io_dfi_dfiwrdata_dfi_wrdata_en)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
// .io_dfi_dfiwrdata_dfi_wdata                     (io_dfi_dfiwrdata_dfi_wdata)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
// .io_dfi_dfiwrdata_dfi_wdata_cs_n                (io_dfi_dfiwrdata_dfi_wdata_cs_n)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
// .io_dfi_dfiwrdata_dfi_wdata_mask                (io_dfi_dfiwrdata_dfi_wdata_mask)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
// .io_dfi_dfirddata_dfi_rddata_en                 (io_dfi_dfirddata_dfi_rddata_en),
// .io_dfi_dfirddata_dfi_rddata                    (dfi_rddata),
// .io_dfi_dfirddata_dfi_rddata_cs_n               (io_dfi_dfirddata_dfi_rddata_cs_n),
// .io_dfi_dfirddata_dfi_rddata_valid              ({2{dfi_rddata_valid}}),
// .io_dfi_dfirddata_dfi_rddata_dbi_n              ('b1) ,
// .io_dfi_dfiupdate_dfi_ctrlupd_req               (io_dfi_dfiupdate_dfi_ctrlupd_req)    ,
// .io_dfi_dfiupdate_dfi_ctrlupd_ack               (io_dfi_dfiupdate_dfi_ctrlupd_ack)    ,
// .io_dfi_dfiupdate_dfi_phyupd_req                (io_dfi_dfiupdate_dfi_phyupd_req)    ,
// .io_dfi_dfiupdate_dfi_phyupd_type               (io_dfi_dfiupdate_dfi_phyupd_type)    ,
// .io_dfi_dfiupdate_dfi_phyupd_ack                (io_dfi_dfiupdate_dfi_phyupd_ack)    ,
// .io_dfi_dfistatus_dfi_data_byte_disable         (io_dfi_dfistatus_dfi_data_byte_disable)    ,
// .io_dfi_dfistatus_dfi_dram_clk_disable          (io_dfi_dfistatus_dfi_dram_clk_disable)    ,
// .io_dfi_dfistatus_dfi_freq_ratio                (io_dfi_dfistatus_dfi_freq_ratio)    ,
// .io_dfi_dfistatus_dfi_init_start                (io_dfi_dfistatus_dfi_init_start)    ,
// .io_dfi_dfistatus_dfi_init_complete             (dfi_init_complete )    ,
// .io_dfi_dfistatus_dfi_parity_in                 ()    ,
// .io_dfi_dfistatus_dfi_alert_n                   ()    ,
// .io_dfi_dfitraining_dfi_rdlvl_req               ()    ,
// .io_dfi_dfitraining_dfi_phy_rdlvl_cs_n          ()    ,
// .io_dfi_dfitraining_dfi_rdlvl_en                ()    ,
// .io_dfi_dfitraining_dfi_rdlvl_resp              ()    ,
// .io_dfi_dfitraining_dfi_rdlvl_gate_req          ()    ,
// .io_dfi_dfitraining_dfi_phy_rdlvl_gate_cs_n     ()    ,
// .io_dfi_dfitraining_dfi_rdlvl_gate_en           ()    ,
// .io_dfi_dfitraining_dfi_wrlvl_req               ()    ,
// .io_dfi_dfitraining_dfi_phy_wrlvl_cs_n          ()    ,
// .io_dfi_dfitraining_dfi_wrlvl_en                ()    ,
// .io_dfi_dfitraining_dfi_wrlvl_strobe            ()    ,
// .io_dfi_dfitraining_dfi_wrlvl_resp              ()    ,
// .io_dfi_dfitraining_dfi_lvl_pattern             ()    ,
// .io_dfi_dfitraining_dfi_lvl_periodic            ()    ,
// .io_dfi_dfitraining_dfi_phylvl_req_cs_n         ()    ,
// .io_dfi_dfitraining_dfi_phylvl_ack_cs_n         ()    ,
// .io_dfi_dfilp_dfi_lp_ctrl_req                   (io_dfi_dfilp_dfi_lp_ctrl_req	)    ,
// .io_dfi_dfilp_dfi_lp_data_req                   ()    ,
// .io_dfi_dfilp_dfi_lp_wakeup                     (io_dfi_dfilp_dfi_lp_wakeup		)    ,
// .io_dfi_dfilp_dfi_lp_ack                        (dfi_lp_ack		)    ,
// .io_apbio_pclk									(pclk),
// .io_apbio_presetn								(o_presetn),
// .io_apbio_paddr									(paddr_baiyang),
// .io_apbio_pwdata								(pwdata_baiyang),
// .io_apbio_pwrite								(pwrite_baiyang),
// .io_apbio_psel									(psel_baiyang),
// .io_apbio_penable								(penable_baiyang),
// .io_apbio_pready								(pready_baiyang),
// .io_apbio_prdata								(prdata_baiyang),
// .io_apbio_pslverr								(pslverr_baiyang)
// );
logic   token_collect_over;
logic   data_collect_over;


   reg   [8*9-1:0] RG_FSM0 ;
    always @(*) begin
        case (ddr_wrapper.u_scg.u_RequestGenerate_0.state)
            0:RG_FSM0 <= "ref      ";
            1:RG_FSM0 <= "QueryPage";
            2:RG_FSM0 <= "preIssue ";
            3:RG_FSM0 <= "ActIssue ";
            4:RG_FSM0 <= "CasIssue ";
            5:RG_FSM0 <= "ClosePage"; 
            default:RG_FSM0 <= "ref      "; 
        endcase
    end
    reg   [8*9-1:0] RG_FSM1 ;
    always @(*) begin
        case (ddr_wrapper.u_scg.u_RequestGenerate_1.state)
            0:RG_FSM1 <= "ref      ";
            1:RG_FSM1 <= "QueryPage";
            2:RG_FSM1 <= "preIssue ";
            3:RG_FSM1 <= "ActIssue ";
            4:RG_FSM1 <= "CasIssue ";
            5:RG_FSM1 <= "ClosePage"; 
            default:RG_FSM1 <= "ref      "; 
        endcase
    end
reg   [8*9-1:0] RG_FSM2 ;
    always @(*) begin
        case (ddr_wrapper.u_scg.u_RequestGenerate_2.state)
            0:RG_FSM2 <= "ref      ";
            1:RG_FSM2 <= "QueryPage";
            2:RG_FSM2 <= "preIssue ";
            3:RG_FSM2 <= "ActIssue ";
            4:RG_FSM2 <= "CasIssue ";
            5:RG_FSM2 <= "ClosePage"; 
            default:RG_FSM2 <= "ref      "; 
        endcase
    end
    reg   [8*9-1:0] RG_FSM3 ;
    always @(*) begin
        case (ddr_wrapper.u_scg.u_RequestGenerate_3.state)
            0:RG_FSM3 <= "ref      ";
            1:RG_FSM3 <= "QueryPage";
            2:RG_FSM3 <= "preIssue ";
            3:RG_FSM3 <= "ActIssue ";
            4:RG_FSM3 <= "CasIssue ";
            5:RG_FSM3 <= "ClosePage"; 
            default:RG_FSM3 <= "ref      "; 
        endcase
    end  

SCG_V2 u_scg(
/*input         */.clock                                          (core_ddrc_core_clk)    ,	// src/main/scala/SCG/scala/SCG.scala:7:7
/*              */.reset                                          (!core_ddrc_rstn)    ,	// src/main/scala/SCG/scala/SCG.scala:7:7
/*              */.io_calDone                                     (training_done )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [35:0] */.io_dfi_dfictrl_dfi_address                     (io_dfi_dfictrl_dfi_address)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [3:0]  */.io_dfi_dfictrl_dfi_bank                        (io_dfi_dfictrl_dfi_bank )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [1:0]  */.io_dfi_dfictrl_dfi_ras_n                       (io_dfi_dfictrl_dfi_ras_n)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.io_dfi_dfictrl_dfi_cas_n                       (io_dfi_dfictrl_dfi_cas_n)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.io_dfi_dfictrl_dfi_we_n                        (io_dfi_dfictrl_dfi_we_n )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.io_dfi_dfictrl_dfi_cs_n                        (io_dfi_dfictrl_dfi_cs_n )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.io_dfi_dfictrl_dfi_act_n                       (io_dfi_dfictrl_dfi_act_n)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [3:0]  */.io_dfi_dfictrl_dfi_bg                          (io_dfi_dfictrl_dfi_bg)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output        */.io_dfi_dfictrl_dfi_cid                         ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [1:0]  */.io_dfi_dfictrl_dfi_cke                         (io_dfi_dfictrl_dfi_cke)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.io_dfi_dfictrl_dfi_odt                         (io_dfi_dfictrl_dfi_odt)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.io_dfi_dfictrl_dfi_reset_n                     (io_dfi_dfictrl_dfi_reset_n)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*
/*output [31:0] */.io_dfi_dfiwrdata_dfi_wrdata_en                 (io_dfi_dfiwrdata_dfi_wrdata_en)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [255:0]*/.io_dfi_dfiwrdata_dfi_wdata                     (io_dfi_dfiwrdata_dfi_wdata)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [31:0] */.io_dfi_dfiwrdata_dfi_wdata_cs_n                (io_dfi_dfiwrdata_dfi_wdata_cs_n)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.io_dfi_dfiwrdata_dfi_wdata_mask                (io_dfi_dfiwrdata_dfi_wdata_mask)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*
/*              */.io_dfi_dfirddata_dfi_rddata_en                 (io_dfi_dfirddata_dfi_rddata_en)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [255:0]*/.io_dfi_dfirddata_dfi_rddata                    (dfi_rddata)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [31:0] */.io_dfi_dfirddata_dfi_rddata_cs_n               (io_dfi_dfirddata_dfi_rddata_cs_n)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [31:0] */.io_dfi_dfirddata_dfi_rddata_valid              (dfi_rddata_valid)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.io_dfi_dfirddata_dfi_rddata_dbi_n              ('b1)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*
/*output        */.io_dfi_dfiupdate_dfi_ctrlupd_req               (io_dfi_dfiupdate_dfi_ctrlupd_req)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input         */.io_dfi_dfiupdate_dfi_ctrlupd_ack               (io_dfi_dfiupdate_dfi_ctrlupd_ack)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.io_dfi_dfiupdate_dfi_phyupd_req                (io_dfi_dfiupdate_dfi_phyupd_req)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [1:0]  */.io_dfi_dfiupdate_dfi_phyupd_type               (io_dfi_dfiupdate_dfi_phyupd_type)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output        */.io_dfi_dfiupdate_dfi_phyupd_ack                (io_dfi_dfiupdate_dfi_phyupd_ack)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [31:0] */.io_dfi_dfistatus_dfi_data_byte_disable         (io_dfi_dfistatus_dfi_data_byte_disable)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [1:0]  */.io_dfi_dfistatus_dfi_dram_clk_disable          (io_dfi_dfistatus_dfi_dram_clk_disable)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.io_dfi_dfistatus_dfi_freq_ratio                (io_dfi_dfistatus_dfi_freq_ratio)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output        */.io_dfi_dfistatus_dfi_init_start                (io_dfi_dfistatus_dfi_init_start)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input         */.io_dfi_dfistatus_dfi_init_complete             (dfi_init_complete)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output        */.io_dfi_dfistatus_dfi_parity_in                 ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [1:0]  */.io_dfi_dfistatus_dfi_alert_n                   ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input         */.io_dfi_dfitraining_dfi_rdlvl_req               ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [1:0]  */.io_dfi_dfitraining_dfi_phy_rdlvl_cs_n          ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output        */.io_dfi_dfitraining_dfi_rdlvl_en                ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [3:0]  */.io_dfi_dfitraining_dfi_rdlvl_resp              ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input         */.io_dfi_dfitraining_dfi_rdlvl_gate_req          ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [1:0]  */.io_dfi_dfitraining_dfi_phy_rdlvl_gate_cs_n     ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output        */.io_dfi_dfitraining_dfi_rdlvl_gate_en           ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [3:0]  */.io_dfi_dfitraining_dfi_wrlvl_req               ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [1:0]  */.io_dfi_dfitraining_dfi_phy_wrlvl_cs_n          ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output        */.io_dfi_dfitraining_dfi_wrlvl_en                ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.io_dfi_dfitraining_dfi_wrlvl_strobe            ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [3:0]  */.io_dfi_dfitraining_dfi_wrlvl_resp              ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [7:0]  */.io_dfi_dfitraining_dfi_lvl_pattern             ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output        */.io_dfi_dfitraining_dfi_lvl_periodic            ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input         */.io_dfi_dfitraining_dfi_phylvl_req_cs_n         ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [1:0]  */.io_dfi_dfitraining_dfi_phylvl_ack_cs_n         ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output        */.io_dfi_dfilp_dfi_lp_ctrl_req                   (io_dfi_dfilp_dfi_lp_ctrl_req)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.io_dfi_dfilp_dfi_lp_data_req                   ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [3:0]  */.io_dfi_dfilp_dfi_lp_wakeup                     (io_dfi_dfilp_dfi_lp_wakeup)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input         */.io_dfi_dfilp_dfi_lp_ack                        (dfi_lp_ack)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*
/*output        */.io_As2ScgCmd_ready                                 (wire_io_as2scg_cmdRdy  )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input         */.io_As2ScgCmd_valid                                 (wire_io_as2scg_cmdValid)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*              */.wire_io_as2scgcmd_bits_adr_cmdtype                 (wire_io_as2scgcmd_bits_adr_cmdtype     )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  	    */.io_As2ScgCmd_bits_ADR_adr_rank                     (wire_io_as2scgcmd_bits_adr_adr_rank    )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [1:0]  */.io_As2ScgCmd_bits_ADR_adr_group                    (wire_io_as2scgcmd_bits_adr_adr_group     )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  	    */.io_As2ScgCmd_bits_ADR_adr_bank                     (wire_io_as2scgcmd_bits_adr_adr_bank   )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [17:0] */.io_As2ScgCmd_bits_ADR_adr_row                      (wire_io_as2scgcmd_bits_adr_adr_row    )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [9:0]  */.io_As2ScgCmd_bits_ADR_adr_col                      (wire_io_as2scgcmd_bits_adr_adr_col     )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [16:0] */.io_As2ScgCmd_bits_ADR_adr_cmdToken                 (wire_io_as2scgcmd_bits_adr_adr_cmdtoken   )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input         */.io_As2ScgCmd_bits_pri                              (wire_io_as2scgcmd_priority)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [512:0]*/.io_As2ScgWrdata_wdata                              (wire_io_as2scg_wrData  )    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [63:0] */.io_As2ScgWrdata_wstrb                              (wire_io_as2scg_dataMask)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14

/*input         */.io_Scg2AsRddata_ready                              ('b1)    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output        */.io_Scg2AsRddata_valid                              ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [255:0]*/.io_Scg2AsRddata_bits_rdata                         ()    ,	// src/main/scala/SCG/scala/SCG.scala:8:14
/*output [4:0]  */.io_Scg2AsRddata_bits_rtoken	                      ()    ,// src/main/scala/SCG/scala/SCG.scala:8:14
/*input  [5:0]  */.io_scgregio_tRRDS								  ()    ,
/*              */.io_scgregio_tRRDL								  ()    ,
/*input  [7:0]  */.io_scgregio_tFAW									  ()    ,
/*input  [5:0]  */.io_scgregio_tRCD									  ()    ,
/*              */.io_scgregio_tRP									  ()    ,	
/*input  [7:0]  */.io_scgregio_tCCDS				  				  ()    ,		
/*              */.io_scgregio_tCCDL								  ()    ,
/*              */.io_scgregio_tWTRS					  			  ()    ,	
/*              */.io_scgregio_tWTRL								  ()    ,
/*              */.io_scgregio_tRTW									  ()    ,
/*              */.io_scgregio_tWR									  ()    ,
/*              */.io_scgregio_tRTP									  ()    ,
/*              */.io_scgregio_tRAS									  ()    ,
/*              */.io_scgregio_AL									  ()    ,
/*              */.io_scgregio_WL									  ()    ,
/*              */.io_scgregio_RL									  ()    ,
/*              */.io_scgregio_BL									  ()    ,
/*input  [15:0  */.io_scgregio_tREFI								  ()    ,
/*input  [31:0  */.io_scgregio_tZQINTVL							  	  ()    ,
/*input  [11:0  */.io_scgregio_tRFC									  ()    ,
/*input  [7:0]  */.io_scgregio_tZQCS								  ()    ,
/*              */.io_scgregio_tphyWrlat							  ()    ,
/*              */.io_scgregio_tphyWrcslat							  ()    ,
/*              */.io_scgregio_tphyWrdata							  ()    ,
/*              */.io_scgregio_trddataEn							  ()    ,
/*              */.io_scgregio_tphyRdcslat							  ()    ,
/*              */.io_scgregio_tphyRdlat							  ()    ,
/*              */.io_scgregio_wrOdtDelay							  ()    ,
/*              */.io_scgregio_wrOdtHold							  ()    ,
/*              */.io_scgregio_rdOdtDelay							  ()    ,
/*              */.io_scgregio_rdOdtHold							  ()    ,
/*input         */.io_scgregio_dfiMode								  ()    ,
/*input  [8:0]  */.io_scgregio_clspgTmInit							  ()    ,
/*input  [1:0]  */.io_scgregio_prePolicy							  ()    ,
/*output [2:0]  */.io_scgregio_RGState_0							  ()    ,
/*              */.io_scgregio_RGState_1							  ()    ,
/*              */.io_scgregio_RGState_2							  ()    ,
/*              */.io_scgregio_RGState_3							  ()    ,
/*              */.io_scgregio_refState								  ()    ,
/*input         */.io_scgregio_dfiInitStart							  ()    ,
/*output        */.io_scgregio_dfiInitComplete						  ()    ,
/*              */.io_scgregio_ddrInitEnd							  ()    ,
/*input  [20:0  */.io_scgregio_dramRstn								  ()    ,
/*input  [10:0  */.io_scgregio_postCke								  ()    ,
/*input  [23:0  */.io_scgregio_preCke								  ()    ,
/*input  [7:0]  */.io_scgregio_mrs2other							  ()    ,
/*input  [3:0]  */.io_scgregio_mrs2mrs								  ()    ,
/*input  [11:0  */.io_scgregio_zqinit								  ()    ,
/*input  [15:0  */.io_scgregio_mrs1									  ()    ,
/*              */.io_scgregio_mrs0									  ()    ,
/*              */.io_scgregio_mrs3									  ()    ,
/*              */.io_scgregio_mrs2									  ()    ,
/*              */.io_scgregio_mrs5									  ()    ,
/*              */.io_scgregio_mrs4									  ()    ,
/*              */.io_scgregio_mrs6									  ()    ,
/*input  [5:0]  */.io_scgregio_cmdGear								  ()    ,
/*input  [7:0]  */.io_scgregio_syncGear								  ()    ,
/*              */.io_scgregio_gearHold								  ()    ,
/*              */.io_scgregio_gearSetup							  ()    ,
/*input         */.io_scgregio_blkTGeardown							  ()    ,
/*              */.io_scgregio_geardownMode							  ()    ,
/*              */.io_calDone										  ()    ,
);
// always@(posedge core_ddrc_core_clk)begin
// 	if(!core_ddrc_rstn)
// 		init_refresh	<=	1'b0;
// 	else if(count == 'd1000)
// 		init_refresh	<=	1'b1;
// 	else
// 		init_refresh	<=	1'b0;
// end

// reg	zqs_end	;
// always@(posedge core_ddrc_core_clk) begin
//    if (!core_ddrc_rstn)
//       zqs_end <= 1'b0;
//    else if (zqs_end)
//       zqs_end <= 1'b1;
//    else if (paddr_mc[15:0] == 'h700 &&  penable_baiyang)
//       zqs_end <= 1'b1;
//    else
//       zqs_end <= 1'b0;
// end

assign dfi_act_n                = 	io_dfi_dfictrl_dfi_act_n                                                   	;
//assign mc_dfi_address           =  training_done      ? {io_dfi_dfictrl_dfi_address[35], io_dfi_dfictrl_dfi_ras_n[1], io_dfi_dfictrl_dfi_cas_n[1], io_dfi_dfictrl_dfi_we_n[1], io_dfi_dfictrl_dfi_address[31:17], io_dfi_dfictrl_dfi_ras_n[0], io_dfi_dfictrl_dfi_cas_n[0], io_dfi_dfictrl_dfi_we_n[0], io_dfi_dfictrl_dfi_address[13:0]}          : DWC_mc_dfi_address ;
assign mc_dfi_address           =   io_dfi_dfictrl_dfi_address													;//training_done ? io_dfi_dfictrl_dfi_address	:(zqs_end ? 36'h11000_4400 : io_dfi_dfictrl_dfi_address)												;
assign dfi_bank                 =   {1'b0, io_dfi_dfictrl_dfi_bank[3:2], 1'b0, io_dfi_dfictrl_dfi_bank[1:0]}                                                  ;
assign dfi_bg                   =  	io_dfi_dfictrl_dfi_bg   	                                                ;
assign mc_dfi_cke               =   {{1'b1}, io_dfi_dfictrl_dfi_cke[1], {1'b1}, io_dfi_dfictrl_dfi_cke[0]}      ;
assign mc_dfi_cs_n              =  	{{1'b1}, io_dfi_dfictrl_dfi_cs_n[1], {1'b1}, io_dfi_dfictrl_dfi_cs_n[0]};//training_done ? {{1'b1}, io_dfi_dfictrl_dfi_cs_n[1], {1'b1}, io_dfi_dfictrl_dfi_cs_n[0]} : {{2{io_dfi_dfictrl_dfi_cs_n[0]}},2'b11}  ;//{{1'b0}, io_dfi_dfictrl_dfi_cs_n[1], {1'b0}, io_dfi_dfictrl_dfi_cs_n[0]}    ;//: (zqs_end?(init_refresh ? 4'h3 : 4'hf )  :{{1'b1}, io_dfi_dfictrl_dfi_cs_n[1], {1'b1}, io_dfi_dfictrl_dfi_cs_n[0]})
assign mc_dfi_odt               =   {{1'b0}, io_dfi_dfictrl_dfi_odt[1], {1'b0}, io_dfi_dfictrl_dfi_odt[0]}                                                  ;
assign dfi_wrdata               =  	io_dfi_dfiwrdata_dfi_wdata                                                  ;
assign mc_dfi_wrdata_en         =  	io_dfi_dfiwrdata_dfi_wrdata_en                                            	;
assign dfi_wrdata_mask          =  	io_dfi_dfiwrdata_dfi_wdata_mask                                             ;
assign mc_dfi_rddata_en         =  	io_dfi_dfirddata_dfi_rddata_en                                            	;
assign dfi_reset_n				=	{2{io_dfi_dfictrl_dfi_reset_n}}												;
assign dfi_dram_clk_disable		=	io_dfi_dfistatus_dfi_dram_clk_disable[0]									;
assign dfi_frequency			=	{2{io_dfi_dfistatus_dfi_freq_ratio}}										;
assign dfi_init_start			=	io_dfi_dfistatus_dfi_init_start												;
assign dfi_lp_req				=	io_dfi_dfilp_dfi_lp_ctrl_req												;
assign dfi_lp_wakeup			=	io_dfi_dfilp_dfi_lp_wakeup													;



endmodule
