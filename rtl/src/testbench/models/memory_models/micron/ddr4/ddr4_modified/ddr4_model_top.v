`timescale 1ps/1ps
module ddr4_model_top #(parameter SEED = 100)(
inout           ddr_dm,
inout   [7:0]   ddr_dq,
inout           ddr_dqs,
inout           ddr_dqsb,
output          ddr_alertn,
input           ddr_ck,
input           ddr_ckb,
input           ddr_actn,
input           ddr_parity,
input           ddr_rstn,
input           ddr_ten,
input           ddr_csb,
input           ddr_cke,
input           ddr_odt,
input           ddr_cid,
input   [1:0]   ddr_bg,
input   [1:0]   ddr_ba,
input   [17:0]  ddr_addr
   );

`ifdef IO_DELAY
wire                 dly_ddr_dm   ;
wire[7:0]            dly_ddr_dq   ;
wire                 dly_ddr_dqs  ;
wire                 dly_ddr_dqsb ;
wire                 wdqs_ctrl_mode;

assign wdqs_ctrl_mode = tb.wdqs_ctrl_mode ;

  io_delay #(.DQ_LANE(1), .SEED(SEED))u_io_delay(
       .wdqs_ctrl_mode(wdqs_ctrl_mode),
       .ddr_dm       ( ddr_dm       ) ,//inout[3:0]
       .ddr_dq       ( ddr_dq       ) ,//inout[31:0]
       .ddr_dqs      ( ddr_dqs      ) ,//inout[3:0]
       .ddr_dqsb     ( ddr_dqsb     ) ,//inout[3:0]
       .dly_ddr_dm   ( dly_ddr_dm   ) ,//output[3:0]
       .dly_ddr_dq   ( dly_ddr_dq   ) , //output[3:0]
       .dly_ddr_dqs  ( dly_ddr_dqs  ) ,//output[3:0]
       .dly_ddr_dqsb ( dly_ddr_dqsb ) ,//output[3:0]
       .ddr_rstn	 ( 1'b0),
       .ddr_ck	     ( 1'b0),
       .ddr_ckb	     ( 1'b0),
       .ddr_cke	     ( 1'b0),
       .ddr_csb	     ( 1'b0),
       .ddr_odt	     ( 1'b0),
       .ddr_ck_b	 ( 1'b0),
       .ddr_ckb_b	 ( 1'b0),
       .ddr_cke_b	 ( 1'b0),
       .ddr_csb_b	 ( 1'b0),
       .ddr_odt_b	 ( 1'b0),
       .ddr_addr	 (18'h0),
       .ddr_ba	     ( 2'h0),
       .ddr_bg	     ( 2'h0),
       .ddr_web	     ( 1'h0),
       .ddr_rasb	 ( 1'h0),
       .ddr_casb	 ( 1'h0),
       .ddr_actn	 ( 1'h0),
       .ddr_bs	     ( 3'h0),
       .dly_ddr_rstn (),
       .dly_ddr_ck	 (),
       .dly_ddr_ckb	 (),
       .dly_ddr_cke	 (),
       .dly_ddr_csb	 (),
       .dly_ddr_odt	 (),
       .dly_ddr_ck_b (),
       .dly_ddr_ckb_b(),
       .dly_ddr_cke_b(),
       .dly_ddr_csb_b(),
       .dly_ddr_odt_b(),
       .dly_ddr_addr (),
       .dly_ddr_ba	 (),
       .dly_ddr_bg	 (),
       .dly_ddr_web	 (),
       .dly_ddr_rasb (),
       .dly_ddr_casb (),
       .dly_ddr_actn (),
       .dly_ddr_bs	 ()
  );

`endif

`ifdef IO_DELAY
//    ddr_cmd_check
//    ddr_cmd_check_inst(
//        .clk           (ddr_ck ),
//        .cs_n          (ddr_csb ) ,
//        .cke           (ddr_cke ) ,
//        .act_n         (ddr_actn ) ,
//        .ras_n         (ddr_addr[16] ) ,
//        .cas_n         (ddr_addr[15] ) ,
//        .we_n          (ddr_addr[14] ) ,
//        .bg            (ddr_bg[1:0]) ,
//        .ba            (ddr_ba[1:0] ) ,
//        .addr          (ddr_addr[17:0])
//        );

    `ifdef VIP
    ddr4 u_ddr4 (
        .ck          (ddr_ck)       ,
        .ckbar       (ddr_ckb)      ,
        .cke         (ddr_cke)      ,
        .csbar       (ddr_csb)      ,
        .actbar      (ddr_actn)     ,
        .odt         (ddr_odt)      ,
        .dmdbi       (dly_ddr_dm)       ,
        .ba          (ddr_ba)       ,
        .bg          (ddr_bg)       ,
        .a           (ddr_addr)     ,
        .dq          (dly_ddr_dq)       ,
        .dqs         (dly_ddr_dqs)      ,
        .dqsbar      (dly_ddr_dqsb)     ,
        .resetbar    (ddr_rstn)     ,
        .alertbar    (ddr_alertn)   ,
        .parin       (ddr_parity)
    );



    `else
        parameter UTYPE_density CONFIGURED_DENSITY = _16G;
        parameter int CONFIGURED_DQ_BITS = 16;
        parameter int CONFIGURED_RANKS = 1;

        wire     model_enable;
        assign   model_enable =1'b1;

        DDR4_if #(.CONFIGURED_DQ_BITS(16)) iDDR4();
        assign   ddr_alertn                =                  iDDR4.ALERT_n;
        alias    iDDR4.DM_n[0]             =                  dly_ddr_dm[0];
        alias    iDDR4.DQ[7:0]             =                  dly_ddr_dq[7:0];
        alias    iDDR4.DQS_t[0]            =                  dly_ddr_dqs[0];
        alias    iDDR4.DQS_c[0]            =                  dly_ddr_dqsb[0];
        assign   iDDR4.CK[1]               =                  ddr_ck;
        assign   iDDR4.CK[0]               =                  ddr_ckb;
        assign   iDDR4.ACT_n               =                  ddr_actn;
        assign   iDDR4.RAS_n_A16           =                  ddr_addr[16];
        assign   iDDR4.CAS_n_A15           =                  ddr_addr[15];
        assign   iDDR4.WE_n_A14            =                  ddr_addr[14];
        assign   iDDR4.PARITY              =                  ddr_parity;
        assign   iDDR4.RESET_n             =                  ddr_rstn;
        assign   iDDR4.TEN                 =                  ddr_ten;
        assign   iDDR4.CS_n                =                  ddr_csb;
        assign   iDDR4.CKE                 =                  ddr_cke;
        assign   iDDR4.ODT                 =                  ddr_odt;
        assign   iDDR4.C                   =                  ddr_cid;
        assign   iDDR4.BG                  =                  ddr_bg;
        assign   iDDR4.BA                  =                  ddr_ba;
        assign   iDDR4.ADDR                =                  ddr_addr[13:0];
        assign   iDDR4.ADDR_17             =                  ddr_addr[17];




    ddr4_model #(.CONFIGURED_DQ_BITS(CONFIGURED_DQ_BITS), .CONFIGURED_DENSITY(CONFIGURED_DENSITY), .CONFIGURED_RANKS(CONFIGURED_RANKS))
    u0_r0
    (
     .model_enable                          (model_enable),
     .iDDR4                                 (iDDR4));

    `endif
`else

//    ddr_cmd_check
//    ddr_cmd_check_inst(
//        .clk           (ddr_ck ),
//        .cs_n          (ddr_csb ) ,
//        .cke           (ddr_cke ) ,
//        .act_n         (ddr_actn ) ,
//        .ras_n         (ddr_addr[16] ) ,
//        .cas_n         (ddr_addr[15] ) ,
//        .we_n          (ddr_addr[14] ) ,
//        .bg            (ddr_bg[1:0]) ,
//        .ba            (ddr_ba[1:0] ) ,
//        .addr          (ddr_addr[17:0])
//        );

    `ifdef VIP
    ddr4 u_ddr4 (
        .ck          (ddr_ck)       ,
        .ckbar       (ddr_ckb)      ,
        .cke         (ddr_cke)      ,
        .csbar       (ddr_csb)      ,
        .actbar      (ddr_actn)     ,
        .odt         (ddr_odt)      ,
        .dmdbi       (ddr_dm)       ,
        .ba          (ddr_ba)       ,
        .bg          (ddr_bg)       ,
        .a           (ddr_addr)     ,
        .dq          (ddr_dq)       ,
        .dqs         (ddr_dqs)      ,
        .dqsbar      (ddr_dqsb)     ,
        .resetbar    (ddr_rstn)     ,
        .alertbar    (ddr_alertn)   ,
        .parin       (ddr_parity)
    );



    `else
        parameter UTYPE_density CONFIGURED_DENSITY = _16G;
        parameter int CONFIGURED_DQ_BITS = 16;
        parameter int CONFIGURED_RANKS = 1;

        wire     model_enable;
        assign   model_enable =1'b1;

        DDR4_if #(.CONFIGURED_DQ_BITS(16)) iDDR4();
        assign   ddr_alertn                =                  iDDR4.ALERT_n;
        alias    iDDR4.DM_n[0]             =                  ddr_dm[0];
        alias    iDDR4.DQ[7:0]             =                  ddr_dq[7:0];
        alias    iDDR4.DQS_t[0]            =                  ddr_dqs[0];
        alias    iDDR4.DQS_c[0]            =                  ddr_dqsb[0];
        assign   iDDR4.CK[1]               =                  ddr_ck;
        assign   iDDR4.CK[0]               =                  ddr_ckb;
        assign   iDDR4.ACT_n               =                  ddr_actn;
        assign   iDDR4.RAS_n_A16           =                  ddr_addr[16];
        assign   iDDR4.CAS_n_A15           =                  ddr_addr[15];
        assign   iDDR4.WE_n_A14            =                  ddr_addr[14];
        assign   iDDR4.PARITY              =                  ddr_parity;
        assign   iDDR4.RESET_n             =                  ddr_rstn;
        assign   iDDR4.TEN                 =                  ddr_ten;
        assign   iDDR4.CS_n                =                  ddr_csb;
        assign   iDDR4.CKE                 =                  ddr_cke;
        assign   iDDR4.ODT                 =                  ddr_odt;
        assign   iDDR4.C                   =                  ddr_cid;
        assign   iDDR4.BG                  =                  ddr_bg;
        assign   iDDR4.BA                  =                  ddr_ba;
        assign   iDDR4.ADDR                =                  ddr_addr[13:0];
        assign   iDDR4.ADDR_17             =                  ddr_addr[17];




    ddr4_model #(.CONFIGURED_DQ_BITS(CONFIGURED_DQ_BITS), .CONFIGURED_DENSITY(CONFIGURED_DENSITY), .CONFIGURED_RANKS(CONFIGURED_RANKS))
    u0_r0
    (
     .model_enable                          (model_enable),
     .iDDR4                                 (iDDR4));

    `endif

`endif


endmodule
