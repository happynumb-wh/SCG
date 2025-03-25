/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Functional Coverage Module for the DDR3 PHY                   *
 *                                                                            *
 *****************************************************************************/

`include "dictionary.v"
`include "macros_define.v"

`ifdef FUNCOV

typedef enum {DDR2 , DDR3} ddr_mode_e;
//DDR2 400 and 533 is not supported due to limitation of pll
//typedef enum {DDR2_533C , DDR2_667C, DDR2_400B , DDR2_800D , DDR2_800E, DDR3_800D , DDR3_1066E , DDR3_1333F , DDR3_1600G } speed_grade_e;
typedef enum {DDR2_667C, DDR2_800D , DDR2_800E, DDR3_800D , DDR3_1066E , DDR3_1333F , DDR3_1600G, DDR3_1866J, DDR3_2133K} speed_grade_e;
typedef enum {MSD_RR_MODE , MSD_RF_MODE} rr_mode_e;
typedef enum {DW_8,DW_16,DW_24,DW_32,DW_40,DW_48,DW_56,DW_64,DW_72} data_width_e;
typedef enum {BL_4,BL_8,BL_V} burst_length_e;
//typedef enum {d2_CL_3,d2_CL_4,d2_CL_5,d2_CL_6} ddr2_cas_lat_e;
typedef enum {d2_CL_4,d2_CL_5,d2_CL_6} ddr2_cas_lat_e;
typedef enum {d3_CL_5,d3_CL_6,d3_CL_7,d3_CL_8,d3_CL_9,d3_CL_10,d3_CL_11,d3_CL_12,d3_CL_13,d3_CL_14} ddr3_cas_lat_e;
typedef enum {CWL_5,CWL_6,CWL_7,CWL_8,CWL_9,CWL_10,CWL_11,CWL_12} cas_wlat_e;
typedef enum {d2_AL_0,d2_AL_1,d2_AL_2,d2_AL_3,d2_AL_4,d2_AL_5} ddr2_add_lat_e;
typedef enum {d3_AL_0,d3_AL_1,d3_AL_2} ddr3_add_lat_e;
typedef enum {M256,M512,M1024,M2048,M4096,M8192} sdram_density_e;
typedef enum {DDR2_256Mbx8,DDR2_256Mbx16,DDR2_512Mbx8,DDR2_512Mbx16,DDR2_1Gbx8,DDR2_1Gbx16,DDR2_2Gbx8,DDR2_2Gbx16,DDR2_4Gbx8,DDR2_4Gbx16} ddr2sdram_cfg_e;
typedef enum {DDR3_512Mbx8,DDR3_512Mbx16,DDR3_1Gbx8,DDR3_1Gbx16,DDR3_2Gbx8,DDR3_2Gbx16,DDR3_4Gbx8,DDR3_4Gbx16,DDR3_8Gbx8,DDR3_8Gbx16} ddr3sdram_cfg_e;
typedef enum {TYPE_I,TYPE_II} wl_sl_enc_e;
typedef enum {BETWEEN_0_90,BETWEEN_90_270,BETWEEN_270_450,BETWEEN_0_135,BETWEEN_135_315,BETWEEN_315_495} wl_sl_delay_e;
typedef enum {WL_SEL_00,WL_SEL_01,WL_SEL_1X} wl_sl_e;
typedef enum {INCREMENTAL_DXnLCDLR2_10PS,DECREMENTAL_DXnLCDLR2_10PS,RANDOM_DXnLCDLR2_10PS} dqs_gating_scn_e;
typedef enum {MSD_ZCTRL_0,MSD_ZCTRL_1,MSD_ZCTRL_2,MSD_ZCTRL_3} zctrl_e;
typedef enum {NO_OF_RANKS_1,NO_OF_RANKS_2,NO_OF_RANKS_3,NO_OF_RANKS_4} ranks_e;
typedef enum {INCREMENT_VT_DRIFT_10PS_WITH_VT_UPDATE, DECREMENT_VT_DRIFT_10PS_WITH_VT_UPDATE,  RANDOM_VT_DRIFT_WITH_VT_UPDATE} vt_drift_scn_e1;
typedef enum {INCREMENT_VT_DRIFT_10PS_WITHOUT_VT_UPDATE, DECREMENT_VT_DRIFT_10PS_WITHOUT_VT_UPDATE, RANDOM_VT_DRIFT_WITHOUT_VT_UPDATE} vt_drift_scn_e2;
typedef enum {PHY_VT_UPD_REQUEST, CTRL_VT_UPD_REQUEST, NO_VT_UPD_REQUEST} vt_upd_req_scn_e;
typedef enum {DQS_GATING,WRITE_LEVELING,VT_DRIFTING,DQS_DRIFTING} ddrphy_engine_e;
typedef enum {INCREMENT_DQS_DQ_DRIFT_10PS, DECREMENT_DQS_DQ_DRIFT_10PS,  RANDOM_DQS_DQ_DRIFT} dqs_dq_drift_scn_e;
typedef enum {DQS_DQ_POS_PHASED_QUARTER_CLOCK,DQS_DQ_POS_PHASED_HALF_CLOCK,DQS_DQ_POS_PHASED_THREE_QUARTER_CLOCK,DQS_DQ_POS_PHASED_FULL_CLOCK,DQS_DQ_NEG_PHASED_QUARTER_CLOCK,DQS_DQ_NEG_PHASED_HALF_CLOCK,DQS_DQ_NEG_PHASED_THREE_QUARTER_CLOCK,DQS_DQ_NEG_PHASED_FULL_CLOCK} dqs_dq_phased_e;
typedef enum {VT_DRIFT_W_DQS_DQ_DRIFT_INCREMENTAL,VT_DRIFT_W_DQS_DQ_DRIFT_RANDOM} vt_dqs_dq_e;
typedef enum {VT_DRIFT_W_WL_INCREMENTAL,VT_DRIFT_W_WL_RANDOM} vt_wl_e;
typedef enum {WALKING_ONES,WALKING_ZEROS,TOGGLE_DATA_ZEROS_AND_ONES,TOGGLE_DATA_As_AND_5s,RANDOM_DATA} pattern_type_e;

`endif

module ddr_fcov();

    
reg [1:0]                   rank;  
reg [2:0]                   bank;
reg [15:0]                  row;
reg [11:0]                  col;
 
reg                         cke;       // SDRAM clock enable
reg                         odt;       // SDRAM on-die termination
reg                         cs_b;      // SDRAM chip select
reg                         ras_b;     // SDRAM row address select
reg                         cas_b;     // SDRAM column address select
reg                         we_b;      // SDRAM write enable
reg [`DWC_BANK_WIDTH-1:0]   ba;        // SDRAM bank address
reg [`DWC_ADDR_WIDTH-1:0]   a;         // SDRAM address
reg [`DWC_NO_OF_BYTES-1:0]   dm;        // SDRAM output data mask
reg [`DWC_NO_OF_BYTES-1:0]   dqs;       // SDRAM input/output data strobe
reg [`DWC_NO_OF_BYTES-1:0]   dqs_b;     // SDRAM input/output data strobe #
reg [`DWC_DATA_WIDTH-1:0]   dq;     


reg [`DWC_DATA_WIDTH-1:0] data_ch_lb_beat0;
reg [`DWC_DATA_WIDTH-1:0] data_ch_lb_beat1;
reg [`DWC_DATA_WIDTH-1:0] data_ch_lb_beat2;
reg [`DWC_DATA_WIDTH-1:0] data_ch_lb_beat3; 
 
reg [15:0]               addr_ch_lb;
  
reg [5:0]                ACBDL_CK0BD;
reg [5:0]                ACBDL_CK1BD;
reg [5:0]                ACBDL_CK2BD;   
reg [5:0]                ACBDL_ACBD;

reg [7:0]                ACMDLD;

reg [5:0]                DQ0WBD; 
reg [5:0]                DQ1WBD;    
reg [5:0]                DQ2WBD; 
reg [5:0]                DQ3WBD; 
reg [5:0]                DQ4WBD;

reg [5:0]                DQ5WBD;
reg [5:0]                DQ6WBD;
reg [5:0]                DQ7WBD;
reg [5:0]                DMWBD;
reg [5:0]                DSWBD;

reg [5:0]                DSOEBD;
reg [5:0]                DQOEBD;   
reg [5:0]                DSRBD;   
reg [5:0]                DSNRBD;   
   
reg [5:0]                DQ0RBD; 
reg [5:0]                DQ1RBD;    
reg [5:0]                DQ2RBD; 
reg [5:0]                DQ3RBD; 
reg [5:0]                DQ4RBD;

reg [5:0]                DQ5RBD;
reg [5:0]                DQ6RBD;
reg [5:0]                DQ7RBD;
reg [5:0]                DMRBD;

reg [7:0]                DXMDLD; 

reg [7:0]                R0WLD;   
reg [7:0]                R1WLD; 
reg [7:0]                R2WLD;
reg [7:0]                R3WLD;
  
reg [7:0]                WDQD;  
reg [7:0]                RDQSD;
reg [7:0]                RDQSND;
 
reg [7:0]                R0DQSGD;
reg [7:0]                R1DQSGD; 
reg [7:0]                R2DQSGD; 
reg [7:0]                R3DQSGD;
 
    
integer                  board_dly;
integer                  board_dly_over_one_clock;
reg [5:0]                ac_bdl_dly_line;   
   
integer                  output_osc_hi_pulse_min_max;   
integer                  output_osc_lo_pulse_min_max;      
integer                  output_osc_period_min_max;
  

reg                      pll_bypass_en;
reg                      test_mode_bypass_en;

integer                  CL;
integer                  nRCD;
integer                  nRP;
integer                  dqs_dq_dft_first_half_range;
integer                  dqs_dq_dft_second_half_range;   
integer                  vt_drift_v;
integer                  dqs_dq_drift_v;
integer                  wl_v;   
integer                  read_data;
integer                  write_data;   
integer                  device;
parameter                tRP_WIDTH        = 4;   
parameter                tACT2RW_WIDTH    = 4;   
parameter                tWR2PRE_WIDTH    = 6;   
parameter                tWRL_WIDTH       = 5;   
parameter                tOL_WIDTH        = 4;   
parameter                tRD2PRE_WIDTH    = 5;   
parameter                tRD2WR_WIDTH     = 4;   
parameter                tWR2RD_WIDTH     = 6;
   
//Timing parameter   
  reg [2:0]                  t_orwl_odd;
  reg [`tMRD_WIDTH:0]        t_mrd;      // load mode to load mode 
  reg [`tRP_WIDTH-1:0]       t_rp;       // precharge to activate
  reg [`tRRD_WIDTH-1:0]      t_rrd;      // activate to activate (diff banks)
  reg [`tRC_WIDTH-1:0]       t_rc;       // activate to activate
  reg [`tFAW_WIDTH-1:0]      t_faw;      // 4-bank active window
  reg [`tRFC_WIDTH-1:0]      t_rfc;      // refresh to refresh (min)
  reg [tRP_WIDTH-1:0]        t_pre2act;
  reg [tACT2RW_WIDTH-1:0]    t_act2rw;
  reg [tRD2PRE_WIDTH-1:0]    t_rd2pre;
  reg [tWR2PRE_WIDTH-1:0]    t_wr2pre;
  reg [tRD2WR_WIDTH-1:0]     t_rd2wr;
  reg [tWR2RD_WIDTH-1:0]     t_wr2rd;
  reg [tRD2PRE_WIDTH-1:0]    t_rdap2act;
  reg [tWR2PRE_WIDTH-1:0]    t_wrap2act; 
 
 
//----    
//ACBDLR
   reg [5:0]                ACBDLR_CK0BD_5_0;
   reg [5:0]                ACBDLR_CK1BD_11_6;
   reg [5:0]                ACBDLR_CK2BD_17_12;   
   reg [5:0]                ACBDLR_ACBD_23_18;

//DX0BDLR0
   reg [5:0]                DX0BDLR0_DQ0WBD_5_0;
   reg [5:0]                DX0BDLR0_DQ1WBD_11_6;
   reg [5:0]                DX0BDLR0_DQ2WBD_17_12;
   reg [5:0]                DX0BDLR0_DQ3WBD_23_18;
   reg [5:0]                DX0BDLR0_DQ4WBD_29_24;

//DX0BDLR1
   reg [5:0]                DX0BDLR1_DQ5WBD_5_0;
   reg [5:0]                DX0BDLR1_DQ6WBD_11_6;
   reg [5:0]                DX0BDLR1_DQ7WBD_17_12;
   reg [5:0]                DX0BDLR1_DMWBD_23_18;
   reg [5:0]                DX0BDLR1_DSWBD_29_24;

//DX0BDLR2
   reg [5:0]                DX0BDLR2_DSOEBD_5_0;
   reg [5:0]                DX0BDLR2_DQOEBD_11_6;
   reg [5:0]                DX0BDLR2_DSRBD_17_12;
   reg [5:0]                DX0BDLR2_DSNRBD_23_18;
 
//DX0BDLR3 
   reg [5:0]                DX0BDLR3_DQ0RBD_5_0;
   reg [5:0]                DX0BDLR3_DQ1RBD_11_6;
   reg [5:0]                DX0BDLR3_DQ2RBD_17_12;
   reg [5:0]                DX0BDLR3_DQ3RBD_23_18;
   reg [5:0]                DX0BDLR3_DQ4RBD_29_24;
  
//DX0BDLR4
   reg [5:0]                DX0BDLR4_DQ5RBD_5_0;
   reg [5:0]                DX0BDLR4_DQ6RBD_11_6;
   reg [5:0]                DX0BDLR4_DQ7RBD_17_12;
   reg [5:0]                DX0BDLR4_DMRBD_23_18;
       
//DX0LCDLR0
   reg [7:0]                DX0LCDLR0_R0WLD_7_0;
   reg [7:0]                DX0LCDLR0_R1WLD_15_8;   
   reg [7:0]                DX0LCDLR0_R2WLD_23_16;
   reg [7:0]                DX0LCDLR0_R3WLD_31_24;
//DX0LCDLR1
   reg [7:0]                DX0LCDLR1_WDQD_7_0;
   reg [7:0]                DX0LCDLR1_RDQSD_15_8;   
   reg [7:0]                DX0LCDLR1_RDQSND_23_16;   
  
//DX0LCDLR2
   reg [7:0]                DX0LCDLR2_R0DQSGD_7_0;
   reg [7:0]                DX0LCDLR2_R1DQSGD_15_8;   
   reg [7:0]                DX0LCDLR2_R2DQSGD_23_16;
   reg [7:0]                DX0LCDLR2_R3DQSGD_31_24;   
//DX0MDLR
   reg [7:0]                DX0MDLR_IPRD_7_0;
   reg [7:0]                DX0MDLR_TPRD_15_8;
   reg [7:0]                DX0MDLR_MDLD_23_16;  
 
      

   
////////////////////////////////////////
////////////////////////////////////////
// Objects from the typdef enumeration
////////////////////////////////////////
////////////////////////////////////////   
`ifdef FUNCOV

ddr_mode_e       ddr_m;
data_width_e     dw_m;
burst_length_e   bl_m;
ddr2_cas_lat_e   d2_cl_m;
ddr3_cas_lat_e   d3_cl_m;  
cas_wlat_e       cwl_m;
ddr2_add_lat_e   d2_al_m;
ddr3_add_lat_e   d3_al_m;
sdram_density_e  sd_m;     
speed_grade_e    speed_gr;
rr_mode_e        rr_m;
ddr2sdram_cfg_e  d2_sdcfg_m;   
ddr3sdram_cfg_e  d3_sdcfg_m;    
wl_sl_enc_e      sl_enc_type;   
wl_sl_delay_e    wl_delay;
wl_sl_e          wl_sel;
dqs_gating_scn_e dqs_gating_scn;
zctrl_e          zctrl_m;
ranks_e          ranks_m;
ddrphy_engine_e ddrphy_engine;
dqs_dq_drift_scn_e  dqs_dq_drift_scn;
dqs_dq_phased_e   dqs_dq_phased;
vt_dqs_dq_e       vt_dqs_dq;
vt_wl_e           vt_wl;  
pattern_type_e    pattern_type;
   
/////////////////////////////////////
/////////////////////////////////////
//Cover Groups
/////////////////////////////////////
/////////////////////////////////////


//--------------------------------------------
// Coverage group for ddr mode
//--------------------------------------------   
   covergroup ddr_mode; 
      type_option.goal = 100;     
      coverpoint ddr_m; 
      option.comment = "Coverage for DDR Mode";           
   endgroup // ddr_mode

//--------------------------------------------
// Coverage group for data width
//--------------------------------------------   
   covergroup data_width; 
      type_option.goal = 100;     
      coverpoint dw_m; 
      option.comment = "Coverage for Data Width ";           
   endgroup // data_width
  
   
//--------------------------------------------
// Coverage group for Zctrl
//--------------------------------------------   
   covergroup zctrl; 
      type_option.goal = 100;     
      coverpoint zctrl_m; 
      option.comment = "Coverage for Zctrl ";           
   endgroup // zctrl


//--------------------------------------------
// Coverage group for sdram ranks
//--------------------------------------------   
   covergroup sdram_ranks; 
      type_option.goal = 100;     
      coverpoint ranks_m; 
      option.comment = "Coverage for sdram ranks ";           
   endgroup // sdram_ranks
      
 
//--------------------------------------------
// Coverage group for burst length
//--------------------------------------------   
   covergroup burst_length; 
      type_option.goal = 100;     
      coverpoint bl_m; 
      option.comment = "Coverage for Burst length ";           
   endgroup // burst_length
   

//--------------------------------------------
// Coverage group for ddr2 cas latency
//--------------------------------------------   
   covergroup ddr2_cas_latency; 
      type_option.goal = 100;     
      coverpoint d2_cl_m; 
      option.comment = "Coverage for DDR2 CAS Latency ";           
   endgroup // ddr2_cas_latency
   
//--------------------------------------------
// Coverage group for ddr3 cas latency
//--------------------------------------------   
   covergroup ddr3_cas_latency; 
      type_option.goal = 100;     
      coverpoint d3_cl_m; 
      option.comment = "Coverage for DDR3 CAS Latency ";           
   endgroup // ddr3_cas_latency
   
//--------------------------------------------
// Coverage group for cas write latency
//--------------------------------------------   
   covergroup cas_write_latency; 
      type_option.goal = 100;     
      coverpoint cwl_m; 
      option.comment = "Coverage for CAS Write Latency ";           
   endgroup // cas_write_latency
   
//--------------------------------------------
// Coverage group for DDR2 Additive latency
//--------------------------------------------   
   covergroup ddr2_additive_latency; 
      type_option.goal = 100;     
      coverpoint d2_al_m; 
      option.comment = "Coverage for DDR2 Additive Latency ";           
   endgroup // ddr2_additive_latency
   
//--------------------------------------------
// Coverage group for DDR3 Additive latency
//--------------------------------------------   
   covergroup ddr3_additive_latency; 
      type_option.goal = 100;     
      coverpoint d3_al_m; 
      option.comment = "Coverage for DDR3 Additive Latency ";           
   endgroup // ddr3_additive_latency
   
//--------------------------------------------
// Coverage group for sdram density
//--------------------------------------------   
   covergroup sdram_density; 
      type_option.goal = 100;     
      coverpoint sd_m; 
      option.comment = "Coverage for SDRAM Density ";           
   endgroup // sdram_density

//----------------------------------------------------------------
// Coverage group for DDR2 sdram configuration (Density,x4,x8,x16)
//----------------------------------------------------------------   
   covergroup ddr2_sdram_cfg; 
      type_option.goal = 100;     
      coverpoint d2_sdcfg_m; 
      option.comment = "Coverage for DDR2 SDRAM configuration  ";           
   endgroup // ddr2_sdram_cfg
   
//----------------------------------------------------------------
// Coverage group for DDR3 sdram configuration (Density,x4,x8,x16)
//----------------------------------------------------------------   
   covergroup ddr3_sdram_cfg; 
      type_option.goal = 100;     
      coverpoint d3_sdcfg_m; 
      option.comment = "Coverage for DDR3 SDRAM configuration  ";           
   endgroup // ddr3_sdram_cfg   


//--------------------------------------------
// Coverage group for MSD RR mode
//--------------------------------------------   
   covergroup rr_mode; 
      type_option.goal = 100;     
      coverpoint rr_m; 
      option.comment = "Coverage for MSD RR Mode";           
   endgroup // rr_mode

//--------------------------------------------
// Coverage group for DDR3 memory timing
//--------------------------------------------   
   covergroup ddr3_memory_timing; 
      type_option.goal = 100;     
      coverpoint t_orwl_odd;      
      coverpoint t_mrd;      
      coverpoint t_rp;      
      coverpoint t_rrd;      
      coverpoint t_rc;      
      coverpoint t_faw;      
      coverpoint t_rfc;      
      coverpoint t_pre2act;      
      coverpoint t_act2rw;      
      coverpoint t_rd2pre;      
      coverpoint t_wr2pre;      
      coverpoint t_rd2wr {
         bins value_4 = {4};
         bins value_5 = {5};
         bins value_6 = {6};
         bins value_7 = {7};
         bins value_8 = {8};
         bins value_9 = {9};                  
      }      
      coverpoint t_wr2rd;      
      coverpoint t_rdap2act;      
      coverpoint t_wrap2act;    
      option.comment = "Coverage for DDR3 Memory timing";           
   endgroup // ddr3_memory_timing
   

//--------------------------------------------
// Coverage group for DDR2 memory timing
//--------------------------------------------   
   covergroup ddr2_memory_timing; 
      type_option.goal = 100;     
      coverpoint t_orwl_odd;      
      coverpoint t_mrd;      
      coverpoint t_rp;      
      coverpoint t_rrd;      
      coverpoint t_rc;      
      coverpoint t_faw;      
      coverpoint t_rfc;      
      coverpoint t_pre2act;      
      coverpoint t_act2rw;      
      coverpoint t_rd2pre;      
      coverpoint t_wr2pre;      
      coverpoint t_rd2wr {         
         bins value_5 = {5};        
         bins value_7 = {7};                                  
      }                               
      coverpoint t_wr2rd;      
      coverpoint t_rdap2act;      
      coverpoint t_wrap2act;    
      option.comment = "Coverage for DDR2 Memory timing";           
   endgroup // ddr2_memory_timing
   

   
//--------------------------------------------
// Coverage group for DDR sdram interface signals
//--------------------------------------------       
   covergroup cov_ddr_sdram_inf_signals;
      type_option.goal = 100;

      coverpoint  cke {
         bins cke_value_0 = {0};
         bins cke_value_1 = {1};              
      }      
      coverpoint  odt {
         bins odt_value_0 = {0};
         bins odt_value_1 = {1};              
      }       
      coverpoint  cs_b {
         bins cs_b_value_0 = {0};
         bins cs_b_value_1 = {1};              
      }            
      coverpoint  ras_b {
         bins ras_b_value_0 = {0};
         bins ras_b_value_1 = {1};              
      }       
      coverpoint  cas_b {
         bins cas_b_value_0 = {0};
         bins cas_b_value_1 = {1};              
      }      
      coverpoint  we_b {
         bins we_b_value_0 = {0};
         bins we_b_value_1 = {1};              
      }  
      coverpoint ba {
         bins ba_value_0  = {0};
         bins ba_value_1  = {1};         
         bins ba_value_2  = {2};
         bins ba_value_3  = {3};                          
         bins ba_value_4  = {4};
         bins ba_value_5  = {5};         
         bins ba_value_6  = {6};
         bins ba_value_7  = {7};                       
      }
         
`ifdef DW_8        
      coverpoint dm {
         bins dm_value_0 = {0};
         bins dm_value_1 = {1};
      }
      coverpoint dqs {
         bins dqs_value_0 = {0};
         bins dqs_value_1 = {1};
      }
      coverpoint dqs_b {
         bins dqs_b_value_0 = {0};
         bins dqs_b_value_1 = {1};                        
      }
      `COVERPOINT_8BITS_TOGGLING(dq)   
`elsif  DW_16
      `COVERPOINT_2BITS_TOGGLING(dm)
      `COVERPOINT_2BITS_TOGGLING(dqs)
      `COVERPOINT_2BITS_TOGGLING(dqs_b)  
      `COVERPOINT_16BITS_TOGGLING(dq)
`elsif  DW_24
      `COVERPOINT_3BITS_TOGGLING(dm)
      `COVERPOINT_3BITS_TOGGLING(dqs)
      `COVERPOINT_3BITS_TOGGLING(dqs_b)  
      `COVERPOINT_24BITS_TOGGLING(dq)      
`elsif  DW_32
      `COVERPOINT_4BITS_TOGGLING(dm)
      `COVERPOINT_4BITS_TOGGLING(dqs)
      `COVERPOINT_4BITS_TOGGLING(dqs_b)  
      `COVERPOINT_32BITS_TOGGLING(dq)                              
`elsif  DW_40
                
`elsif  DW_48
              
`elsif  DW_56
                      
`elsif  DW_64
      `COVERPOINT_8BITS_TOGGLING(dm)
      `COVERPOINT_8BITS_TOGGLING(dqs)
      `COVERPOINT_8BITS_TOGGLING(dqs_b)  
      `COVERPOINT_64BITS_TOGGLING(dq)           
`elsif  DW_72
      `COVERPOINT_9BITS_TOGGLING(dm)
      `COVERPOINT_9BITS_TOGGLING(dqs)
      `COVERPOINT_9BITS_TOGGLING(dqs_b)  
      `COVERPOINT_72BITS_TOGGLING(dq)                 
`endif                  

`ifdef MSD_4GB_SUPPORT  
        `COVERPOINT_16BITS_TOGGLING(a) //DDR_ROW_WIDTH 16
`elsif MSD_2GB_SUPPORT
        `COVERPOINT_15BITS_TOGGLING(a) //DDR_ROW_WIDTH 15
`else
        `COVERPOINT_14BITS_TOGGLING(a) //DDR_ROW_WIDTH 14   
`endif
   endgroup // cov_ddr_sdram_inf_signals
               
//--------------------------------------------
// Coverage group for memory address
//--------------------------------------------

// ------------------ DDR 2 ---------------------------- //
`ifdef DDR2
   covergroup cov_address_ddr2 ;
      type_option.goal = 100;

      coverpoint rank {
         bins rank_value_0 = {0};
         bins rank_value_1 = {1};         
         bins rank_value_2 = {2};
         bins rank_value_3 = {3};      
      }

      // max row width = 16, max col width =  10 (not counting x4 configuration)                       
      `COVERPOINT_16BITS_TOGGLING(row)
      `COVERPOINT_10BITS_TOGGLING(col)  

      coverpoint bank {
         bins bank_value_0  = {0};
         bins bank_value_1  = {1};
         bins bank_value_2  = {2};
         bins bank_value_3  = {3};
         bins bank_value_4  = {4};
         bins bank_value_5  = {5};
         bins bank_value_6  = {6};
         bins bank_value_7  = {7};
      }   

      coverpoint d2_sdcfg_m {
         bins sdram_cfg_DDR2_256Mbx8   = {DDR2_256Mbx8};
         bins sdram_cfg_DDR2_256Mbx16  = {DDR2_256Mbx16};                
         bins sdram_cfg_DDR2_512Mbx8   = {DDR2_512Mbx8};                
         bins sdram_cfg_DDR2_512Mbx16  = {DDR2_512Mbx16};                
         bins sdram_cfg_DDR2_1Gbx8     = {DDR2_1Gbx8};                
         bins sdram_cfg_DDR2_1Gbx16    = {DDR2_1Gbx16};                
         bins sdram_cfg_DDR2_2Gbx8     = {DDR2_2Gbx8};                
         bins sdram_cfg_DDR2_2Gbx16    = {DDR2_2Gbx16};                
         bins sdram_cfg_DDR2_4Gbx8     = {DDR2_4Gbx8};                
         bins sdram_cfg_DDR2_4Gbx16    = {DDR2_4Gbx16};                
      }
      cross d2_sdcfg_m , col;
      cross d2_sdcfg_m , row;
      cross d2_sdcfg_m , bank;
      cross d2_sdcfg_m , rank;     

      option.comment = "Coverage for memory address for DDR2";      
   endgroup // cov_address_ddr2
`endif


// ------------------ DDR 3 ---------------------------- //
`ifdef DDR3
   covergroup cov_address_ddr3 ;
      type_option.goal = 100;

      coverpoint rank {
         bins rank_value_0 = {0};
         bins rank_value_1 = {1};         
         bins rank_value_2 = {2};
         bins rank_value_3 = {3};      
      }

      // max row width = 16, max col width =  11 (not counting x4 configuration)                       
      `COVERPOINT_16BITS_TOGGLING(row)
      `COVERPOINT_11BITS_TOGGLING(col)     

      coverpoint bank {
         bins bank_value_0  = {0};
         bins bank_value_1  = {1};
         bins bank_value_2  = {2};
         bins bank_value_3  = {3};
         bins bank_value_4  = {4};
         bins bank_value_5  = {5};
         bins bank_value_6  = {6};
         bins bank_value_7  = {7};
      }

      coverpoint d3_sdcfg_m {
         bins sdram_cfg_DDR3_512Mbx8   = {DDR3_512Mbx8};                
         bins sdram_cfg_DDR3_512Mbx16  = {DDR3_512Mbx16};                
         bins sdram_cfg_DDR3_1Gbx8     = {DDR3_1Gbx8};                
         bins sdram_cfg_DDR3_1Gbx16    = {DDR3_1Gbx16};                
         bins sdram_cfg_DDR3_2Gbx8     = {DDR3_2Gbx8};                
         bins sdram_cfg_DDR3_2Gbx16    = {DDR3_2Gbx16};                
         bins sdram_cfg_DDR3_4Gbx8     = {DDR3_4Gbx8};                
         bins sdram_cfg_DDR3_4Gbx16    = {DDR3_4Gbx16};                
         bins sdram_cfg_DDR3_8Gbx8     = {DDR3_8Gbx8};                
         bins sdram_cfg_DDR3_8Gbx16    = {DDR3_8Gbx16};                
      }     
      cross d3_sdcfg_m , col;
      cross d3_sdcfg_m , row;
      cross d3_sdcfg_m , bank;
      cross d3_sdcfg_m , rank;        
      option.comment = "Coverage for memory address for DDR3";      
   endgroup // cov_address_ddr3
`endif

                               

//--------------------------------------------
// Coverage group for DDR3 CL-nRCD-nRP
//--------------------------------------------       
   covergroup d3_CL_nRCD_nRP ;
      type_option.goal = 100;
      coverpoint CL {
         bins CL_value_5   = {5};
         bins CL_value_6   = {6};
         bins CL_value_7   = {7};
         bins CL_value_8   = {8};       
      } 
      coverpoint nRCD {
         bins nRCD_value_5 = {5};
         bins nRCD_value_6 = {6};
         bins nRCD_value_7 = {7};
         bins nRCD_value_8 = {8};         
      }
      coverpoint nRP {
        bins nRP_value_5   = {5};
        bins nRP_value_6   = {6};
        bins nRP_value_7   = {7};
        bins nRP_value_8   = {8};       
      }

      coverpoint speed_gr {
         bins speed_gr_DDR3_800D  = {DDR3_800D};     
         bins speed_gr_DDR3_1066E = {DDR3_1066E};
         bins speed_gr_DDR3_1333F = {DDR3_1333F};     
         bins speed_gr_DDR3_1600G = {DDR3_1600G};         
         bins speed_gr_DDR3_1866G = {DDR3_1866J};         
         bins speed_gr_DDR3_2133K = {DDR3_2133K};         
      }        
     
         cross speed_gr , CL , nRCD , nRP 
         {
            bins CL_nRCD_nRP_DDR3_800D_5_5_5 = (binsof(speed_gr) intersect {DDR3_800D}) && (binsof(CL) intersect {5}) && (binsof(nRCD) intersect {5}) && (binsof(nRP) intersect {5});
            bins CL_nRCD_nRP_DDR3_1066E_6_6_6 = (binsof(speed_gr) intersect {DDR3_1066E}) && (binsof(CL) intersect {6}) && (binsof(nRCD) intersect {6}) && (binsof(nRP) intersect {6});
            bins CL_nRCD_nRP_DDR3_1333F_7_7_7 = (binsof(speed_gr) intersect {DDR3_1333F}) && (binsof(CL) intersect {7}) && (binsof(nRCD) intersect {7}) && (binsof(nRP) intersect {7});
            bins CL_nRCD_nRP_DDR3_1600G_8_8_8 = (binsof(speed_gr) intersect {DDR3_1600G}) && (binsof(CL) intersect {8}) && (binsof(nRCD) intersect {8}) && (binsof(nRP) intersect {8});
            bins CL_nRCD_nRP_DDR3_1866J_10_10_10 = (binsof(speed_gr) intersect {DDR3_1866J}) && (binsof(CL) intersect {10}) && (binsof(nRCD) intersect {10}) && (binsof(nRP) intersect {10});
            bins CL_nRCD_nRP_DDR3_2133K_11_11_11 = (binsof(speed_gr) intersect {DDR3_2133K}) && (binsof(CL) intersect {11}) && (binsof(nRCD) intersect {11}) && (binsof(nRP) intersect {11});
            ignore_bins CL_nRCD_nRP0_DDR3 = ( (binsof(CL) intersect {5}) && (binsof(nRCD) intersect {5}) && (binsof(nRP) intersect {6,7,8}));
            ignore_bins CL_nRCD_nRP1_DDR3 = ( (binsof(CL) intersect {5}) && (!binsof(nRCD) intersect {5}) && (binsof(nRP) intersect {5,6,7,8}));
            ignore_bins CL_nRCD_nRP2_DDR3 = ( (binsof(CL) intersect {6}) && (binsof(nRCD) intersect {6}) && (binsof(nRP) intersect {5,7,8}));
            ignore_bins CL_nRCD_nRP3_DDR3 = ( (binsof(CL) intersect {6}) && (!binsof(nRCD) intersect {6}) && (binsof(nRP) intersect {5,6,7,8}));
            ignore_bins CL_nRCD_nRP4_DDR3 = ( (binsof(CL) intersect {7}) && (binsof(nRCD) intersect {7}) && (binsof(nRP) intersect {5,6,8}));
            ignore_bins CL_nRCD_nRP5_DDR3 = ( (binsof(CL) intersect {7}) && (!binsof(nRCD) intersect {7}) && (binsof(nRP) intersect {5,6,7,8}));
            ignore_bins CL_nRCD_nRP6_DDR3 = ( (binsof(CL) intersect {8}) && (binsof(nRCD) intersect {8}) && (binsof(nRP) intersect {5,6,7}));
            ignore_bins CL_nRCD_nRP7_DDR3 = ( (binsof(CL) intersect {8}) && (!binsof(nRCD) intersect {8}) && (binsof(nRP) intersect {5,6,7,8}));           
            ignore_bins CL_nRCD_nRP8_DDR3 = ( (binsof(speed_gr) intersect {DDR3_800D}) && (binsof(CL) intersect {6,7,8}) && (binsof(nRCD) intersect {6,7,8}) && (binsof(nRP) intersect {6,7,8}));    
            ignore_bins CL_nRCD_nRP9_DDR3 = ( (binsof(speed_gr) intersect {DDR3_1066E}) && (binsof(CL) intersect {5,7,8}) && (binsof(nRCD) intersect {5,7,8}) && (binsof(nRP) intersect {5,7,8}));       
            ignore_bins CL_nRCD_nRP10_DDR3 = ( (binsof(speed_gr) intersect {DDR3_1333F}) && (binsof(CL) intersect {5,6,8}) && (binsof(nRCD) intersect {5,6,8}) && (binsof(nRP) intersect {5,6,8}));       
            ignore_bins CL_nRCD_nRP11_DDR3 = ( (binsof(speed_gr) intersect {DDR3_1600G}) && (binsof(CL) intersect {5,6,7}) && (binsof(nRCD) intersect {5,6,7}) && (binsof(nRP) intersect {5,6,7}));         
         }
           
      option.comment = "Coverage for memory DDR3 parameters CL - nRCD -nRP";      
      endgroup // d3_CL_nRCD_nRP
   
      
 
//--------------------------------------------
// Coverage group for DDR2 CL-nRCD-nRP
//--------------------------------------------       
   covergroup d2_CL_nRCD_nRP ;
      type_option.goal = 100;
      coverpoint CL {
         bins CL_value_4   = {4};
         bins CL_value_5   = {5};
         bins CL_value_6   = {6};        
      } 
      coverpoint nRCD {
         bins nRCD_value_4 = {4};
         bins nRCD_value_5 = {5};
         bins nRCD_value_6 = {6};                
      }
      coverpoint nRP {
        bins nRP_value_4   = {4};
        bins nRP_value_5   = {5};
        bins nRP_value_6   = {6};               
      }

      coverpoint speed_gr {
         bins speed_gr_DDR2_667C  = {DDR2_667C};     
         bins speed_gr_DDR2_800D =  {DDR2_800D};
         bins speed_gr_DDR2_800E =  {DDR2_800E}; 
      }        
     
         cross speed_gr , CL , nRCD , nRP 
         {
            bins CL_nRCD_nRP_DDR2_667C_4_4_4 = (binsof(speed_gr) intersect {DDR2_667C}) && (binsof(CL) intersect {4}) && (binsof(nRCD) intersect {4}) && (binsof(nRP) intersect {4});
            bins CL_nRCD_nRP_DDR2_800D_5_5_5 = (binsof(speed_gr) intersect {DDR2_800D}) && (binsof(CL) intersect {5}) && (binsof(nRCD) intersect {5}) && (binsof(nRP) intersect {5});
            bins CL_nRCD_nRP_DDR2_800E_6_6_6 = (binsof(speed_gr) intersect {DDR2_800E}) && (binsof(CL) intersect {6}) && (binsof(nRCD) intersect {6}) && (binsof(nRP) intersect {6});        
            ignore_bins CL_nRCD_nRP0_DDR2 = ( (binsof(CL) intersect {4}) && (binsof(nRCD) intersect {4}) && (binsof(nRP) intersect {5,6}));
            ignore_bins CL_nRCD_nRP1_DDR3 = ( (binsof(CL) intersect {4}) && (!binsof(nRCD) intersect {4}) && (binsof(nRP) intersect {4,5,6}));
            ignore_bins CL_nRCD_nRP2_DDR2 = ( (binsof(CL) intersect {5}) && (binsof(nRCD) intersect {5}) && (binsof(nRP) intersect {4,6}));
            ignore_bins CL_nRCD_nRP3_DDR2 = ( (binsof(CL) intersect {5}) && (!binsof(nRCD) intersect {5}) && (binsof(nRP) intersect {4,5,6}));
            ignore_bins CL_nRCD_nRP4_DDR2 = ( (binsof(CL) intersect {6}) && (binsof(nRCD) intersect {6}) && (binsof(nRP) intersect {4,5}));
            ignore_bins CL_nRCD_nRP5_DDR2 = ( (binsof(CL) intersect {6}) && (!binsof(nRCD) intersect {6}) && (binsof(nRP) intersect {4,5,6}));           
            ignore_bins CL_nRCD_nRP8_DDR2 = ( (binsof(speed_gr) intersect {DDR2_667C}) && (binsof(CL) intersect {5,6}) && (binsof(nRCD) intersect {5,6}) && (binsof(nRP) intersect {5,6}));    
            ignore_bins CL_nRCD_nRP9_DDR2 = ( (binsof(speed_gr) intersect {DDR2_800D}) && (binsof(CL) intersect {4,6}) && (binsof(nRCD) intersect {4,6}) && (binsof(nRP) intersect {4,6}));
            ignore_bins CL_nRCD_nRP10_DDR2 = ( (binsof(speed_gr) intersect {DDR2_800E}) && (binsof(CL) intersect {4,5}) && (binsof(nRCD) intersect {4,5}) && (binsof(nRP) intersect {4,5})); 
         }
           
      option.comment = "Coverage for memory DDR2 parameters CL - nRCD -nRP";      
      endgroup // d2_CL_nRCD_nRP
   
  
//--------------------------------------------
// Coverage group for memory speed grade
//--------------------------------------------    
   covergroup speed_grade;  
      type_option.goal = 100;    
      coverpoint speed_gr; 
      option.comment = "Coverage for speed grade";             
   endgroup // speed_grade

//--------------------------------------------
// Coverage group for clock timing modes
//--------------------------------------------
   covergroup clock_timing_mission_mode;      
      type_option.goal = 100;  
      option.comment = "Coverage for mission mode with speed grade and rr mode";
      cross speed_gr , rr_m;      
   endgroup // mission_mode
   

   covergroup clock_timing_bypass_mode;      
      type_option.goal = 100;  
      option.comment = "Coverage for bypass mode with speed grade and rr mode";
      cross speed_gr , rr_m;      
   endgroup // bypass_mode

   covergroup clock_timing_test_mode_bypass;      
      type_option.goal = 100;  
      option.comment = "Coverage for test mode bypass with speed grade and rr mode";
      cross speed_gr , rr_m;      
   endgroup   
   

//--------------------------------------------------
// Coverage group for DDR3 parameters AL-CL-BL-CWL
//--------------------------------------------------
   covergroup AL_BL_CL_CWL_DDR3;      
      type_option.goal = 100; 
     
      coverpoint speed_gr {            
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }
      option.comment = "Coverage for AL/BL/CL/CWL for DDR3";
      cross speed_gr, d3_al_m , bl_m , d3_cl_m , cwl_m {            
            ignore_bins speed_al_bl_cl_cwl_0 = ((binsof(speed_gr)) && (binsof(d3_al_m)) && (binsof(bl_m) ) && (binsof(d3_cl_m) intersect {d3_CL_5}) && (binsof(cwl_m) intersect {CWL_6,CWL_7,CWL_8}));
            ignore_bins speed_al_bl_cl_cwl_1 = ((binsof(speed_gr)) && (binsof(d3_al_m)) && (binsof(bl_m) ) && (binsof(d3_cl_m) intersect {d3_CL_6}) && (binsof(cwl_m) intersect {CWL_7,CWL_8}));
            ignore_bins speed_al_bl_cl_cwl_2 = ((binsof(speed_gr)) && (binsof(d3_al_m)) && (binsof(bl_m) ) && (binsof(d3_cl_m) intersect {d3_CL_7}) && (binsof(cwl_m) intersect {CWL_5,CWL_8}));
            ignore_bins speed_al_bl_cl_cwl_3 = ((binsof(speed_gr)) && (binsof(d3_al_m)) && (binsof(bl_m) ) && (binsof(d3_cl_m) intersect {d3_CL_8}) && (binsof(cwl_m) intersect {CWL_5}));
            ignore_bins speed_al_bl_cl_cwl_4 = ((binsof(speed_gr)) && (binsof(d3_al_m)) && (binsof(bl_m) ) && (binsof(d3_cl_m) intersect {d3_CL_9}) && (binsof(cwl_m) intersect {CWL_5,CWL_6}));
            ignore_bins speed_al_bl_cl_cwl_5 = ((binsof(speed_gr)) && (binsof(d3_al_m)) && (binsof(bl_m) ) && (binsof(d3_cl_m) intersect {d3_CL_10}) && (binsof(cwl_m) intersect {CWL_5,CWL_6}));
            ignore_bins speed_al_bl_cl_cwl_6 = ((binsof(speed_gr)) && (binsof(d3_al_m)) && (binsof(bl_m) ) && (binsof(d3_cl_m) intersect {d3_CL_11}) && (binsof(cwl_m) intersect {CWL_5,CWL_6,CWL_7}));       
      }
   endgroup // AL_BL_CL_CWL_DDR3

//--------------------------------------------------
// Coverage group for DDR2 parameters AL-CL-BL-CWL
//--------------------------------------------------
   covergroup AL_BL_CL_CWL_DDR2;      
      type_option.goal = 100;
      coverpoint speed_gr {             
         bins speed_gr_DDR2_800D = {DDR2_800D};
         bins speed_gr_DDR2_800E = {DDR2_800E};    
      }
      coverpoint bl_m {
         bins bl_4 = {BL_4};
         bins bl_8 = {BL_8};              
      }
      option.comment = "Coverage for AL/BL/CL/CWL for DDR2";
      cross speed_gr ,d2_al_m , bl_m , d2_cl_m  {          
            //ignore_bins speed_al_bl_cl_cwl_0 = ((binsof(speed_gr) intersect {DDR2_800D}) && (binsof(d2_al_m)) && (binsof(bl_m) ) && (binsof(d2_cl_m) intersect {d2_CL_3,d2_CL_6}));
            //ignore_bins speed_al_bl_cl_cwl_1 = ((binsof(speed_gr) intersect {DDR2_800E}) && (binsof(d2_al_m)) && (binsof(bl_m) ) && (binsof(d2_cl_m) intersect {d2_CL_3,d2_CL_4,d2_CL_5}));
            ignore_bins speed_al_bl_cl_cwl_0 = ((binsof(speed_gr) intersect {DDR2_800D}) && (binsof(d2_al_m)) && (binsof(bl_m) ) && (binsof(d2_cl_m) intersect {d2_CL_6}));
            ignore_bins speed_al_bl_cl_cwl_1 = ((binsof(speed_gr) intersect {DDR2_800E}) && (binsof(d2_al_m)) && (binsof(bl_m) ) && (binsof(d2_cl_m) intersect {d2_CL_4,d2_CL_5}));
      }     
   endgroup // AL_BL_CL_CWL_DDR2      
   
//--------------------------------------------
// Coverage for write leveling board delays
//--------------------------------------------    
   covergroup wl_board_delays;  
      type_option.goal = 100;    
      coverpoint board_dly {                  
         bins wl_board_delay_0_50 = {[0:50]};
         bins wl_board_delay_50_100 = {[50:100]};
         bins wl_board_delay_100_150 = {[100:150]};
         bins wl_board_delay_150_200 = {[150:200]};
         bins wl_board_delay_200_250 = {[200:250]};
         bins wl_board_delay_250_300 = {[250:300]};
         bins wl_board_delay_300_350 = {[300:350]};
         bins wl_board_delay_350_400 = {[350:400]};
         bins wl_board_delay_400_450 = {[400:450]};
         bins wl_board_delay_450_500 = {[450:500]};
         bins wl_board_delay_500_550 = {[500:550]};
         bins wl_board_delay_550_600 = {[550:600]};
         bins wl_board_delay_600_650 = {[600:650]};
         bins wl_board_delay_650_700 = {[650:700]};
         bins wl_board_delay_700_750 = {[700:750]};
         bins wl_board_delay_750_800 = {[750:800]};
         bins wl_board_delay_800_850 = {[800:850]};
         bins wl_board_delay_850_900 = {[850:900]};
         bins wl_board_delay_900_950 = {[900:950]};
         bins wl_board_delay_950_1000 = {[950:1000]};
         bins wl_board_delay_1000_1050 = {[1000:1050]};
         bins wl_board_delay_1050_1100 = {[1050:1100]};
         bins wl_board_delay_1100_1150 = {[1100:1150]};
         bins wl_board_delay_1150_1200 = {[1150:1200]};
         bins wl_board_delay_1200_1250 = {[1200:1250]};
         bins wl_board_delay_1250_1500 = {[1250:1500]};
         //bins wl_board_delay_1300_1350 = {[1300:1350]};//for frequency 1600 we cannot go over 1250ps
         //bins wl_board_delay_1350_1400 = {[1350:1400]};
         //bins wl_board_delay_1400_1450 = {[1400:1450]};
         //bins wl_board_delay_1450_1500 = {[1450:1500]}; 
    }
      coverpoint speed_gr {
         bins speed_gr_DDR3_800D = {DDR3_800D};
         bins speed_gr_DDR3_1600G = {DDR3_1600G};        
      }

      coverpoint ranks_m {
         bins sdram_ranks_4  = {NO_OF_RANKS_4};                    
      }    
  
      cross  speed_gr , ranks_m , board_dly; 
      option.comment = "Coverage for board delays";     
   endgroup // wl_board_delays


//--------------------------------------------
// Coverage for DQS/DQ DRIFT for 1600G
//--------------------------------------------    
   covergroup dqs_dq_drift;  
      type_option.goal = 100; 
      `COVERPOINT_DQS_DQ1(dqs_dq_dft_first_half_range)   
      `COVERPOINT_DQS_DQ2(dqs_dq_dft_second_half_range)         
      coverpoint speed_gr {        
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }

      coverpoint ranks_m {
         bins sdram_ranks_4  = {NO_OF_RANKS_4};                    
      }    
  
      cross  dqs_dq_drift_scn, speed_gr , ranks_m , dqs_dq_dft_first_half_range;
      cross  dqs_dq_drift_scn, speed_gr , ranks_m , dqs_dq_dft_second_half_range;
      option.comment = "Coverage for DQS/DQ DRIFT";     
    endgroup // dqs_dq_drift
   

   //---------------------------------------------------------
   // Coverage group for DQS/DQ  drift scenarios
   //---------------------------------------------------------

   covergroup dqs_dq_drift_scenario;      
      type_option.goal = 100; 
      coverpoint dqs_dq_drift_scn;      
      option.comment = "Coverage for DQS/DQ drift scenarios";                                        
   endgroup // dqs_dq_drift_scenario
   
      
//--------------------------------------------
// Coverage for DQS/DQ PHASED for 1600G
//--------------------------------------------    
   covergroup dqs_dq_fixed_phase;  
      type_option.goal = 100;

      coverpoint dqs_dq_phased;             
      coverpoint speed_gr {        
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }
      coverpoint ranks_m {
         bins sdram_ranks_4  = {NO_OF_RANKS_4};                    
      }    
  
      cross  dqs_dq_phased, speed_gr , ranks_m ;
      cross  dqs_dq_phased, speed_gr , ranks_m ;
      option.comment = "Coverage for DQS/DQ PHASING";     
   endgroup // dqs_dq_phasing
   

//--------------------------------------------
// Coverage for VT drift with DQS/DQ drift for 1600G
//--------------------------------------------    
   covergroup vt_drift_w_dqs_dq_drift;  
      type_option.goal = 100;
   
      //`COVERPOINT_VT_DRIFT(ACBDLR_CK0BD_5_0)
      //`COVERPOINT_VT_DRIFT(ACBDLR_CK1BD_11_6)
      //`COVERPOINT_VT_DRIFT(ACBDLR_CK2BD_17_12)
      //`COVERPOINT_VT_DRIFT(ACBDLR_ACBD_23_18)
      `COVERPOINT_VT_DRIFT(DX0BDLR0_DQ0WBD_5_0)
      `COVERPOINT_VT_DRIFT(DX0BDLR0_DQ1WBD_11_6)
      `COVERPOINT_VT_DRIFT(DX0BDLR0_DQ2WBD_17_12)
      `COVERPOINT_VT_DRIFT(DX0BDLR0_DQ3WBD_23_18)
      `COVERPOINT_VT_DRIFT(DX0BDLR0_DQ4WBD_29_24)
      `COVERPOINT_VT_DRIFT(DX0BDLR1_DQ5WBD_5_0)
      `COVERPOINT_VT_DRIFT(DX0BDLR1_DQ6WBD_11_6)
      `COVERPOINT_VT_DRIFT(DX0BDLR1_DQ7WBD_17_12)
      `COVERPOINT_VT_DRIFT(DX0BDLR1_DMWBD_23_18)
      `COVERPOINT_VT_DRIFT(DX0BDLR1_DSWBD_29_24)
      `COVERPOINT_VT_DRIFT(DX0BDLR2_DSOEBD_5_0)
      `COVERPOINT_VT_DRIFT(DX0BDLR2_DQOEBD_11_6)
      `COVERPOINT_VT_DRIFT(DX0BDLR2_DSRBD_17_12)
      `COVERPOINT_VT_DRIFT(DX0BDLR2_DSNRBD_23_18)
      `COVERPOINT_VT_DRIFT(DX0BDLR3_DQ0RBD_5_0)  
      `COVERPOINT_VT_DRIFT(DX0BDLR3_DQ1RBD_11_6)
      `COVERPOINT_VT_DRIFT(DX0BDLR3_DQ2RBD_17_12)
      `COVERPOINT_VT_DRIFT(DX0BDLR3_DQ3RBD_23_18)
      `COVERPOINT_VT_DRIFT(DX0BDLR3_DQ4RBD_29_24)
      `COVERPOINT_VT_DRIFT(DX0BDLR4_DQ5RBD_5_0)
      `COVERPOINT_VT_DRIFT(DX0BDLR4_DQ6RBD_11_6)
      `COVERPOINT_VT_DRIFT(DX0BDLR4_DQ7RBD_17_12)
      `COVERPOINT_VT_DRIFT(DX0BDLR4_DMRBD_23_18)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR0_R0WLD_7_0)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR0_R1WLD_15_8)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR0_R2WLD_23_16)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR0_R3WLD_31_24)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR1_WDQD_7_0)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR1_RDQSD_15_8)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR1_RDQSND_23_16)
      `COVERPOINT_VT_DRIFT_2(DX0LCDLR2_R0DQSGD_7_0)    
      `COVERPOINT_VT_DRIFT_2(DX0LCDLR2_R1DQSGD_15_8)           
      `COVERPOINT_VT_DRIFT_2(DX0LCDLR2_R2DQSGD_23_16)    
      `COVERPOINT_VT_DRIFT_2(DX0LCDLR2_R3DQSGD_31_24)        
      //`COVERPOINT_VT_DRIFT(DX0MDLR_IPRD_7_0)    
      `COVERPOINT_VT_DRIFT_2(DX0MDLR_TPRD_15_8)       
      `COVERPOINT_VT_DRIFT_2(DX0MDLR_MDLD_23_16)                            
      `COVERPOINT_DQS_DQ_DRIFT(dqs_dq_drift_v)              
      coverpoint vt_dqs_dq;                   
      coverpoint ranks_m {
         bins sdram_ranks_4  = {NO_OF_RANKS_4};                    
      }    
  
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR0_DQ0WBD_5_0,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR0_DQ1WBD_11_6,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR0_DQ2WBD_17_12,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR0_DQ3WBD_23_18,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR0_DQ4WBD_29_24,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR1_DQ5WBD_5_0,dqs_dq_drift_v;
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR1_DQ6WBD_11_6,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR1_DQ7WBD_17_12,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR1_DMWBD_23_18,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR1_DSWBD_29_24,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR2_DSOEBD_5_0,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR2_DQOEBD_11_6,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR2_DSRBD_17_12,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR2_DSNRBD_23_18,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR3_DQ0RBD_5_0,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR3_DQ1RBD_11_6,dqs_dq_drift_v;
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR3_DQ2RBD_17_12,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR3_DQ3RBD_23_18,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR3_DQ4RBD_29_24,dqs_dq_drift_v;
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR4_DQ5RBD_5_0,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR4_DQ6RBD_11_6,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR4_DQ7RBD_17_12,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0BDLR4_DMRBD_23_18,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0LCDLR0_R0WLD_7_0,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0LCDLR0_R1WLD_15_8,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0LCDLR0_R2WLD_23_16,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0LCDLR0_R3WLD_31_24,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0LCDLR1_WDQD_7_0,dqs_dq_drift_v;
      cross  vt_dqs_dq,  ranks_m ,DX0LCDLR1_RDQSD_15_8,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0LCDLR1_RDQSND_23_16,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0LCDLR2_R0DQSGD_7_0,dqs_dq_drift_v; 
      cross  vt_dqs_dq,  ranks_m ,DX0LCDLR2_R1DQSGD_15_8,dqs_dq_drift_v;  
      cross  vt_dqs_dq,  ranks_m ,DX0LCDLR2_R2DQSGD_23_16,dqs_dq_drift_v;  
      cross  vt_dqs_dq,  ranks_m ,DX0LCDLR2_R3DQSGD_31_24,dqs_dq_drift_v; 
      //cross  vt_dqs_dq,  ranks_m ,DX0MDLR_IPRD_7_0,dqs_dq_drift_v;
      cross  vt_dqs_dq,  ranks_m ,DX0MDLR_TPRD_15_8,dqs_dq_drift_v;
      cross  vt_dqs_dq,  ranks_m ,DX0MDLR_MDLD_23_16,dqs_dq_drift_v;  
    
      option.comment = "Coverage for DQS/DQ PHASING";     
   endgroup // vt_drift_w_dqs_dq_drift
   




//--------------------------------------------
// Coverage for VT drift with WL for 1600G
//--------------------------------------------    
   covergroup vt_drift_w_wl;  
      type_option.goal = 100;
   
      //`COVERPOINT_VT_DRIFT(ACBDLR_CK0BD_5_0)
      //`COVERPOINT_VT_DRIFT(ACBDLR_CK1BD_11_6)
      //`COVERPOINT_VT_DRIFT(ACBDLR_CK2BD_17_12)
      //`COVERPOINT_VT_DRIFT(ACBDLR_ACBD_23_18)
      `COVERPOINT_VT_DRIFT(DX0BDLR0_DQ0WBD_5_0)
      `COVERPOINT_VT_DRIFT(DX0BDLR0_DQ1WBD_11_6)
      `COVERPOINT_VT_DRIFT(DX0BDLR0_DQ2WBD_17_12)
      `COVERPOINT_VT_DRIFT(DX0BDLR0_DQ3WBD_23_18)
      `COVERPOINT_VT_DRIFT(DX0BDLR0_DQ4WBD_29_24)
      `COVERPOINT_VT_DRIFT(DX0BDLR1_DQ5WBD_5_0)
      `COVERPOINT_VT_DRIFT(DX0BDLR1_DQ6WBD_11_6)
      `COVERPOINT_VT_DRIFT(DX0BDLR1_DQ7WBD_17_12)
      `COVERPOINT_VT_DRIFT(DX0BDLR1_DMWBD_23_18)
      `COVERPOINT_VT_DRIFT(DX0BDLR1_DSWBD_29_24)
      `COVERPOINT_VT_DRIFT(DX0BDLR2_DSOEBD_5_0)
      `COVERPOINT_VT_DRIFT(DX0BDLR2_DQOEBD_11_6)
      `COVERPOINT_VT_DRIFT(DX0BDLR2_DSRBD_17_12)
      `COVERPOINT_VT_DRIFT(DX0BDLR2_DSNRBD_23_18)
      `COVERPOINT_VT_DRIFT(DX0BDLR3_DQ0RBD_5_0)  
      `COVERPOINT_VT_DRIFT(DX0BDLR3_DQ1RBD_11_6)
      `COVERPOINT_VT_DRIFT(DX0BDLR3_DQ2RBD_17_12)
      `COVERPOINT_VT_DRIFT(DX0BDLR3_DQ3RBD_23_18)
      `COVERPOINT_VT_DRIFT(DX0BDLR3_DQ4RBD_29_24)
      `COVERPOINT_VT_DRIFT(DX0BDLR4_DQ5RBD_5_0)
      `COVERPOINT_VT_DRIFT(DX0BDLR4_DQ6RBD_11_6)
      `COVERPOINT_VT_DRIFT(DX0BDLR4_DQ7RBD_17_12)
      `COVERPOINT_VT_DRIFT(DX0BDLR4_DMRBD_23_18)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR0_R0WLD_7_0)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR0_R1WLD_15_8)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR0_R2WLD_23_16)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR0_R3WLD_31_24)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR1_WDQD_7_0)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR1_RDQSD_15_8)
      `COVERPOINT_VT_DRIFT_1(DX0LCDLR1_RDQSND_23_16)
      `COVERPOINT_VT_DRIFT_2(DX0LCDLR2_R0DQSGD_7_0)    
      `COVERPOINT_VT_DRIFT_2(DX0LCDLR2_R1DQSGD_15_8)           
      `COVERPOINT_VT_DRIFT_2(DX0LCDLR2_R2DQSGD_23_16)    
      `COVERPOINT_VT_DRIFT_2(DX0LCDLR2_R3DQSGD_31_24)        
      //`COVERPOINT_VT_DRIFT(DX0MDLR_IPRD_7_0)    
      `COVERPOINT_VT_DRIFT_2(DX0MDLR_TPRD_15_8)       
      `COVERPOINT_VT_DRIFT_2(DX0MDLR_MDLD_23_16)                            
      `COVERPOINT_WL(wl_v)              
      coverpoint vt_wl;                   
      coverpoint ranks_m {
         bins sdram_ranks_4  = {NO_OF_RANKS_4};                    
      }    
  
      cross  vt_wl,  ranks_m ,DX0BDLR0_DQ0WBD_5_0,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR0_DQ1WBD_11_6,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR0_DQ2WBD_17_12,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR0_DQ3WBD_23_18,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR0_DQ4WBD_29_24,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR1_DQ5WBD_5_0,wl_v;
      cross  vt_wl,  ranks_m ,DX0BDLR1_DQ6WBD_11_6,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR1_DQ7WBD_17_12,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR1_DMWBD_23_18,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR1_DSWBD_29_24,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR2_DSOEBD_5_0,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR2_DQOEBD_11_6,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR2_DSRBD_17_12,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR2_DSNRBD_23_18,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR3_DQ0RBD_5_0,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR3_DQ1RBD_11_6,wl_v;
      cross  vt_wl,  ranks_m ,DX0BDLR3_DQ2RBD_17_12,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR3_DQ3RBD_23_18,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR3_DQ4RBD_29_24,wl_v;
      cross  vt_wl,  ranks_m ,DX0BDLR4_DQ5RBD_5_0,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR4_DQ6RBD_11_6,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR4_DQ7RBD_17_12,wl_v; 
      cross  vt_wl,  ranks_m ,DX0BDLR4_DMRBD_23_18,wl_v; 
      cross  vt_wl,  ranks_m ,DX0LCDLR0_R0WLD_7_0,wl_v; 
      cross  vt_wl,  ranks_m ,DX0LCDLR0_R1WLD_15_8,wl_v; 
      cross  vt_wl,  ranks_m ,DX0LCDLR0_R2WLD_23_16,wl_v; 
      cross  vt_wl,  ranks_m ,DX0LCDLR0_R3WLD_31_24,wl_v; 
      cross  vt_wl,  ranks_m ,DX0LCDLR1_WDQD_7_0,wl_v;
      cross  vt_wl,  ranks_m ,DX0LCDLR1_RDQSD_15_8,wl_v; 
      cross  vt_wl,  ranks_m ,DX0LCDLR1_RDQSND_23_16,wl_v; 
      cross  vt_wl,  ranks_m ,DX0LCDLR2_R0DQSGD_7_0,wl_v; 
      cross  vt_wl,  ranks_m ,DX0LCDLR2_R1DQSGD_15_8,wl_v;  
      cross  vt_wl,  ranks_m ,DX0LCDLR2_R2DQSGD_23_16,wl_v;  
      cross  vt_wl,  ranks_m ,DX0LCDLR2_R3DQSGD_31_24,wl_v; 
      //cross  vt_wl,  ranks_m ,DX0MDLR_IPRD_7_0,wl_v;
      cross  vt_wl,  ranks_m ,DX0MDLR_TPRD_15_8,wl_v;
      cross  vt_wl,  ranks_m ,DX0MDLR_MDLD_23_16,wl_v;  
    
      option.comment = "Coverage for VT drift with WL";     
   endgroup // vt_drift_w_wl
   

   
//------------------------------------------------------
// Coverage group for Data Lines deskew 
//------------------------------------------------------
   covergroup data_lines_deskew;  
      type_option.goal = 100;    

      `COVERPOINT_DATA_SKEW(read_data)
      `COVERPOINT_DATA_SKEW(write_data)  
      `COVERPOINT_DEVICE(device)
      coverpoint ddrphy_engine;
      coverpoint ranks_m {
         bins sdram_ranks_4  = {NO_OF_RANKS_4};                    
      } 
     
      cross ranks_m , device, read_data;
      cross ranks_m , device, write_data;
      cross ddrphy_engine , read_data;
      cross ddrphy_engine , write_data;
      option.comment = "Coverage for Data Lines Deskew";     
    endgroup // data_lines_deskew       

 
//------------------------------------------------------
// Coverage group for WL board delays over 1 sdram clock
//------------------------------------------------------
   covergroup wl_board_delays_over_one_clock;  
      type_option.goal = 100;    
      coverpoint board_dly_over_one_clock {
         bins wl_board_delay_over_one_clock_0 = {[0:9]};
         bins wl_board_delay_over_one_clock_10 = {[10:19]};
         bins wl_board_delay_over_one_clock_20 = {[20:29]};
         bins wl_board_delay_over_one_clock_30 = {[30:39]};
         bins wl_board_delay_over_one_clock_40 = {[40:49]};
         bins wl_board_delay_over_one_clock_50 = {[50:59]};
         bins wl_board_delay_over_one_clock_60 = {[60:69]};
         bins wl_board_delay_over_one_clock_70 = {[70:79]};
         bins wl_board_delay_over_one_clock_80 = {[80:89]};
         bins wl_board_delay_over_one_clock_90 = {[90:99]};
         bins wl_board_delay_over_one_clock_100 = {100};
      }

    coverpoint speed_gr {
         bins speed_gr_DDR3_800D = {DDR3_800D};
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      } 

    coverpoint ranks_m {
         bins sdram_ranks_4  = {NO_OF_RANKS_4};                    
      } 
     
      cross speed_gr , ranks_m ,board_dly_over_one_clock; 
      option.comment = "Coverage for board delays over one clock";     
    endgroup // wl_board_delays_over_one_clock
   

//-----------------------------------------------
// Coverage group for AC BDL delay line linearity
//-----------------------------------------------
   covergroup ac_bdl_dly_line_linearity;      
      type_option.goal = 100;
      coverpoint ACBDL_CK0BD;
      coverpoint ACBDL_CK1BD;
      coverpoint ACBDL_CK2BD;
      coverpoint ACBDL_ACBD;

      coverpoint speed_gr {         
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }  

      cross speed_gr , ACBDL_CK0BD;
      cross speed_gr , ACBDL_CK1BD;
      cross speed_gr , ACBDL_CK2BD;
      cross speed_gr , ACBDL_ACBD;
           
   endgroup // ac_bdl_dly_line_linearity

   
//-----------------------------------------------
// Coverage group for AC MDL delay line linearity
//----------------------------------------------- 
   covergroup ac_mdl_dly_line_linearity;      
      type_option.goal = 100;
      `COVERPOINT_64_4BIT_RANGE(ACMDLD) 

      coverpoint speed_gr {         
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }         

      cross speed_gr , ACMDLD;
            
   endgroup // ac_mdl_dly_line_linearity


//-----------------------------------------------
// Coverage group for DX BDL R0 delay line linearity
//-----------------------------------------------
   covergroup dx_bdl_r0_dly_line_linearity;      
      type_option.goal = 100;
      coverpoint DQ0WBD;
      coverpoint DQ1WBD;
      coverpoint DQ2WBD;
      coverpoint DQ3WBD;
      coverpoint DQ4WBD;  

      coverpoint speed_gr {         
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }    

      cross speed_gr , DQ0WBD;
      cross speed_gr , DQ1WBD;
      cross speed_gr , DQ2WBD;
      cross speed_gr , DQ3WBD;
      cross speed_gr , DQ4WBD; 
           
   endgroup // dx_bdl_r0_dly_line_linearity
   
//-----------------------------------------------
// Coverage group for DX BDL R1 delay line linearity
//-----------------------------------------------
   covergroup dx_bdl_r1_dly_line_linearity;      
      type_option.goal = 100;
      coverpoint DQ5WBD;
      coverpoint DQ6WBD;
      coverpoint DQ7WBD;
      coverpoint DMWBD;
      coverpoint DSWBD; 

      coverpoint speed_gr {         
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }     

      cross speed_gr , DQ5WBD;
      cross speed_gr , DQ6WBD;
      cross speed_gr , DQ7WBD;
      cross speed_gr , DMWBD;
      cross speed_gr , DSWBD; 
           
   endgroup // dx_bdl_r1_dly_line_linearity


//-----------------------------------------------
// Coverage group for DX BDL R2 delay line linearity
//-----------------------------------------------
   covergroup dx_bdl_r2_dly_line_linearity;      
      type_option.goal = 100;
      coverpoint DSOEBD;
      coverpoint DQOEBD;
      coverpoint DSRBD;
      coverpoint DSNRBD;

      coverpoint speed_gr {         
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }
      
      cross speed_gr , DSOEBD;
      cross speed_gr , DQOEBD;
      cross speed_gr , DSRBD;
      cross speed_gr , DSNRBD;
      
   
           
   endgroup // dx_bdl_r2_dly_line_linearity
   

//-----------------------------------------------
// Coverage group for DX BDL R3 delay line linearity
//-----------------------------------------------
   covergroup dx_bdl_r3_dly_line_linearity;      
      type_option.goal = 100;
      coverpoint DQ0RBD;
      coverpoint DQ1RBD;
      coverpoint DQ2RBD;
      coverpoint DQ3RBD;
      coverpoint DQ4RBD; 

      coverpoint speed_gr {         
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }     

      cross speed_gr , DQ0RBD;
      cross speed_gr , DQ1RBD;
      cross speed_gr , DQ2RBD;
      cross speed_gr , DQ3RBD;
      cross speed_gr , DQ4RBD; 
           
   endgroup // dx_bdl_r3_dly_line_linearity 

//-----------------------------------------------
// Coverage group for DX BDL R4 delay line linearity
//-----------------------------------------------
   covergroup dx_bdl_r4_dly_line_linearity;      
      type_option.goal = 100;
      coverpoint DQ5RBD;
      coverpoint DQ6RBD;
      coverpoint DQ7RBD;
      coverpoint DMRBD;

      coverpoint speed_gr {         
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }     

      cross speed_gr , DQ5RBD;
      cross speed_gr , DQ6RBD;
      cross speed_gr , DQ7RBD;
      cross speed_gr , DMRBD;
           
   endgroup // dx_bdl_r4_dly_line_linearity


//-----------------------------------------------
// Coverage group for DX MDL delay line linearity
//----------------------------------------------- 
   covergroup dx_mdl_dly_line_linearity;      
      type_option.goal = 100;
      `COVERPOINT_64_4BIT_RANGE(DXMDLD)   

      coverpoint speed_gr {         
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }  
        
      cross speed_gr , DXMDLD;
            
   endgroup // dx_mdl_dly_line_linearity
   
 
//-----------------------------------------------
// Coverage group for DX LCDL R0 delay line linearity
//----------------------------------------------- 
   covergroup dx_lcdl_r0_dly_line_linearity;      
      type_option.goal = 100;
      `COVERPOINT_64_4BIT_RANGE(R0WLD)
      //`COVERPOINT_64_4BIT_RANGE(R1WLD) //No need to cover all ranks in linearity scenario
      //`COVERPOINT_64_4BIT_RANGE(R2WLD) //No need to cover all ranks in linearity scenario
      //`COVERPOINT_64_4BIT_RANGE(R3WLD) //No need to cover all ranks in linearity scenario

      coverpoint speed_gr {         
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }  
        
      cross speed_gr , R0WLD;         
            
   endgroup // dx_lcdl_r0_dly_line_linearity
   

//-----------------------------------------------
// Coverage group for DX LCDL R1 delay line linearity
//----------------------------------------------- 
   covergroup dx_lcdl_r1_dly_line_linearity;      
      type_option.goal = 100;
      `COVERPOINT_64_4BIT_RANGE(WDQD)
      `COVERPOINT_64_4BIT_RANGE(RDQSD)
      `COVERPOINT_64_4BIT_RANGE(RDQSND)

      coverpoint speed_gr {         
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }  
        
      cross speed_gr , WDQD;
      cross speed_gr , RDQSD;     
      cross speed_gr , RDQSND;     
            
      endgroup // dx_lcdl_r1_dly_line_linearity
   
 
//-----------------------------------------------
// Coverage group for DX LCDL R2 delay line linearity
//----------------------------------------------- 
   covergroup dx_lcdl_r2_dly_line_linearity;      
      type_option.goal = 100;
      `COVERPOINT_64_4BIT_RANGE(R0DQSGD)
      //`COVERPOINT_64_4BIT_RANGE(R1DQSGD) //No need to cover all ranks in linearity scenario
      //`COVERPOINT_64_4BIT_RANGE(R2DQSGD) //No need to cover all ranks in linearity scenario
      //`COVERPOINT_64_4BIT_RANGE(R3DQSGD) //No need to cover all ranks in linearity scenario

      coverpoint speed_gr {         
         bins speed_gr_DDR3_1600G = {DDR3_1600G};
      }  
  
      cross speed_gr , R0DQSGD;        
            
   endgroup // dx_lcdl_r2_dly_line_linearity
   
//---------------------------------------------------------
// Coverage group for AC delay line oscillator mode timing
//---------------------------------------------------------
   covergroup ac_dly_line_osc_mode_time;      
      type_option.goal = 100;
      coverpoint output_osc_hi_pulse_min_max {  // Min X 100 , Max X 100  
        bins mode_timing_hi_range_651_750 = {[651:750]};
        bins mode_timing_hi_range_751_850 = {[751:850]};
        bins mode_timing_hi_range_851_950 = {[851:950]};
        bins mode_timing_hi_range_951_1050 = {[951:1050]};
        bins mode_timing_hi_range_1051_1150 = {[1051:1150]};
        bins mode_timing_hi_range_1151_1250 = {[1151:1250]};
        bins mode_timing_hi_range_1251_1350 = {[1251:1350]};
        bins mode_timing_hi_range_1351_1450 = {[1351:1450]};
        bins mode_timing_hi_range_1451_1529 = {[1451:1529]};
      }           
      coverpoint output_osc_lo_pulse_min_max {  // Min X 100 , Max X 100  
        bins mode_timing_lo_range_651_750 = {[661:760]};
        bins mode_timing_lo_range_751_850 = {[761:860]};
        bins mode_timing_lo_range_851_950 = {[861:960]};
        bins mode_timing_lo_range_951_1050 = {[961:1060]};
        bins mode_timing_lo_range_1051_1150 = {[1061:1160]};
        bins mode_timing_lo_range_1151_1250 = {[1161:1260]};
        bins mode_timing_lo_range_1251_1350 = {[1261:1360]};
        bins mode_timing_lo_range_1351_1450 = {[1361:1460]};
        bins mode_timing_lo_range_1451_1529 = {[1461:1563]};                                              
      }
      coverpoint output_osc_period_min_max {   // Min X 100 , Max X 100 
        bins mode_timing_period_range_1312_1411 = {[1312:1411]};
        bins mode_timing_period_range_1412_1511 = {[1412:1511]};
        bins mode_timing_period_range_1512_1611 = {[1512:1611]};
        bins mode_timing_period_range_1612_1711 = {[1612:1711]};
        bins mode_timing_period_range_1712_1811 = {[1712:1811]};
        bins mode_timing_period_range_1812_1911 = {[1812:1911]};
        bins mode_timing_period_range_1912_2011 = {[1912:2011]}; 
        bins mode_timing_period_range_2012_2111 = {[2012:2111]};                                         
        bins mode_timing_period_range_2112_2211 = {[2112:2211]};
        bins mode_timing_period_range_2212_2311 = {[2212:2311]};
        bins mode_timing_period_range_2312_2411 = {[2312:2411]};
        bins mode_timing_period_range_2412_2511 = {[2412:2512]};
        bins mode_timing_period_range_2512_2611 = {[2512:2611]};
        bins mode_timing_period_range_2612_2711 = {[2612:2711]};
        bins mode_timing_period_range_2712_2811 = {[2712:2812]};
        bins mode_timing_period_range_2912_3092 = {[2912:3092]};    
      }
   endgroup // ac_dly_line_osc_mode_time

//---------------------------------------------------------
// Coverage group for DX delay line oscillator mode timing
//---------------------------------------------------------
   covergroup dx_dly_line_osc_mode_time;      
      type_option.goal = 100;
      coverpoint output_osc_hi_pulse_min_max {  // Min X 100 , Max X 100  
        bins mode_timing_hi_range_458_557 = {[458:557]};
        bins mode_timing_hi_range_558_657 = {[558:657]};
        bins mode_timing_hi_range_658_757 = {[658:757]};
        bins mode_timing_hi_range_758_857 = {[758:857]};
        bins mode_timing_hi_range_858_957 = {[858:957]};         
        bins mode_timing_hi_range_958_1080 = {[958:1080]};         
      }           
      coverpoint output_osc_lo_pulse_min_max {  // Min X 100 , Max X 100  
        bins mode_timing_lo_range_456_555 = {[456:555]};
        bins mode_timing_lo_range_556_655 = {[556:655]};
        bins mode_timing_lo_range_656_755 = {[656:755]};
        bins mode_timing_lo_range_756_855 = {[756:855]};
        bins mode_timing_lo_range_856_955 = {[856:955]}; 
        bins mode_timing_lo_range_956_1080 = {[956:1087]};                                            
      }
      coverpoint output_osc_period_min_max {   // Min X 100 , Max X 100 
        bins mode_timing_period_range_914_1013 = {[914:1013]};
        bins mode_timing_period_range_1014_1113 = {[1014:1113]};
        bins mode_timing_period_range_1114_1213 = {[1114:1213]};
        bins mode_timing_period_range_1214_1313 = {[1214:1313]};
        bins mode_timing_period_range_1314_1413 = {[1314:1413]};
        bins mode_timing_period_range_1414_1513 = {[1414:1513]};
        bins mode_timing_period_range_1514_1613 = {[1514:1613]};
        bins mode_timing_period_range_1614_1713 = {[1614:1713]};
        bins mode_timing_period_range_1714_1813 = {[1714:1813]};
        bins mode_timing_period_range_1814_1913 = {[1814:1913]};
        bins mode_timing_period_range_1914_2013 = {[1914:2013]};
        bins mode_timing_period_range_2014_2113 = {[2014:2113]};
        bins mode_timing_period_range_2114_2167 = {[2114:2167]};                                         
      
      }      
  
   endgroup // dx_dly_line_osc_mode_time   
   

//---------------------------------------------------------
// Coverage group for data  channel loopback
//---------------------------------------------------------
   covergroup data_channel_loopback;      
      type_option.goal = 100;      
       coverpoint pattern_type;
       `COVERPOINT_72BITS_TOGGLING(data_ch_lb_beat0)
       `COVERPOINT_72BITS_TOGGLING(data_ch_lb_beat1)
       `COVERPOINT_72BITS_TOGGLING(data_ch_lb_beat2)
       `COVERPOINT_72BITS_TOGGLING(data_ch_lb_beat3)         
                                                     
   endgroup // data_channel_loopback
   

//---------------------------------------------------------
// Coverage group for address  channel loopback
//---------------------------------------------------------
   covergroup address_channel_loopback;      
      type_option.goal = 100;      

      `COVERPOINT_16BITS_TOGGLING(addr_ch_lb)
                                                                         
    endgroup // address_channel_loopback
   
   
//---------------------------------------------------------
// Coverage group for write level select encoding
//---------------------------------------------------------
   covergroup write_level_sl_encoding;      
      type_option.goal = 100;      
      coverpoint sl_enc_type;
      coverpoint wl_sel;
      coverpoint wl_delay;   

      cross wl_sel,sl_enc_type,wl_delay {

        bins TYPE_I_WL_SEL_00_BETWEEN_0_90  = ( (binsof(wl_sel) intersect {WL_SEL_00}) && (binsof(wl_delay) intersect {BETWEEN_0_90}) && (binsof(sl_enc_type) intersect {TYPE_I}));
        bins TYPE_I_WL_SEL_01_BETWEEN_90_270  = ( (binsof(wl_sel) intersect {WL_SEL_01}) && (binsof(wl_delay) intersect {BETWEEN_90_270}) && (binsof(sl_enc_type) intersect {TYPE_I}));
        bins TYPE_I_WL_SEL_1X_BETWEEN_270_450  = ( (binsof(wl_sel) intersect {WL_SEL_1X}) && (binsof(wl_delay) intersect {BETWEEN_270_450}) && (binsof(sl_enc_type) intersect {TYPE_I}));
        bins TYPE_II_WL_SEL_00_BETWEEN_0_135  = ( (binsof(wl_sel) intersect {WL_SEL_00}) && (binsof(wl_delay) intersect {BETWEEN_0_135}) && (binsof(sl_enc_type) intersect {TYPE_II}));
        bins TYPE_II_WL_SEL_01_BETWEEN_135_315  = ( (binsof(wl_sel) intersect {WL_SEL_01}) && (binsof(wl_delay) intersect {BETWEEN_135_315}) && (binsof(sl_enc_type) intersect {TYPE_II}));
        bins TYPE_II_WL_SEL_1X_BETWEEN_315_495  = ( (binsof(wl_sel) intersect {WL_SEL_1X}) && (binsof(wl_delay) intersect {BETWEEN_315_495}) && (binsof(sl_enc_type) intersect {TYPE_II}));  
                 
       ignore_bins TYPE_WLSEL_WLDLY_1  = ( (binsof(wl_sel) intersect {WL_SEL_00}) && (binsof(wl_delay) intersect {BETWEEN_90_270,BETWEEN_270_450,BETWEEN_0_135,BETWEEN_135_315,BETWEEN_315_495}) && (binsof(sl_enc_type) intersect {TYPE_I}));
       ignore_bins TYPE_WLSEL_WLDLY_2  = ( (binsof(wl_sel) intersect {WL_SEL_00}) && (binsof(wl_delay) intersect {BETWEEN_0_90,BETWEEN_90_270,BETWEEN_270_450,BETWEEN_135_315,BETWEEN_315_495}) && (binsof(sl_enc_type) intersect {TYPE_II}));
       ignore_bins TYPE_WLSEL_WLDLY_3  = ( (binsof(wl_sel) intersect {WL_SEL_01}) && (binsof(wl_delay) intersect {BETWEEN_0_90,BETWEEN_270_450,BETWEEN_0_135,BETWEEN_135_315,BETWEEN_315_495}) && (binsof(sl_enc_type) intersect {TYPE_I}) );
       ignore_bins TYPE_WLSEL_WLDLY_4  = ( (binsof(wl_sel) intersect {WL_SEL_01}) && (binsof(wl_delay) intersect {BETWEEN_0_90,BETWEEN_90_270,BETWEEN_270_450,BETWEEN_0_135,BETWEEN_315_495}) && (binsof(sl_enc_type) intersect {TYPE_II}) ); 
       ignore_bins TYPE_WLSEL_WLDLY_5  = ( (binsof(wl_sel) intersect {WL_SEL_1X}) && (binsof(wl_delay) intersect {BETWEEN_0_90,BETWEEN_90_270,BETWEEN_0_135,BETWEEN_135_315,BETWEEN_315_495}) && (binsof(sl_enc_type) intersect {TYPE_I}) );
       ignore_bins TYPE_WLSEL_WLDLY_6  = ( (binsof(wl_sel) intersect {WL_SEL_1X}) && (binsof(wl_delay) intersect {BETWEEN_0_90,BETWEEN_90_270,BETWEEN_270_450,BETWEEN_0_135,BETWEEN_135_315}) && (binsof(sl_enc_type) intersect {TYPE_II}) );  
         
      }
      
      option.comment = "Coverage for write level select encoding";                                        
   endgroup // write_level_sl_encoding   


//---------------------------------------------------------
// Coverage group for dqs gating scenario
//---------------------------------------------------------

   covergroup dqs_gating_scenario;      
      type_option.goal = 100; 
      coverpoint dqs_gating_scn;            
      option.comment = "Coverage for DQS gating scenarios";                                        
   endgroup // dqs_gating_scenario


//---------------------------------------------------------
// Coverage group for DDRPHY Engines
//---------------------------------------------------------

   covergroup ddrphy_engines;      
      type_option.goal = 100; 
      coverpoint ddrphy_engine;           
      option.comment = "Coverage for DDRPHY Engines";  

      cross ddrphy_engine,speed_gr {
       //ignore_bins ddrphy_engine_speed_gr  = ( (binsof(ddrphy_engine) intersect {WRITE_LEVELING}) && (binsof(speed_gr) intersect {DDR2_800E , DDR2_800D , DDR2_400B , DDR2_667C , DDR2_533C}));
       ignore_bins ddrphy_engine_speed_gr  = ( (binsof(ddrphy_engine) intersect {WRITE_LEVELING}) && (binsof(speed_gr) intersect {DDR2_800E , DDR2_800D , DDR2_667C}));
       }
   endgroup // ddrphy_engines
   


      
/////////////////////////////////////
/////////////////////////////////////
//Declaration of cover group objects
/////////////////////////////////////
/////////////////////////////////////   
   ddr_mode                          ddrmcov;
   data_width                        dwmcov;
   zctrl                             zctrlcov;
   sdram_ranks                       rankscov;   
   burst_length                      blcov;   
   ddr2_cas_latency                  d2_clcov;
   ddr3_cas_latency                  d3_clcov;
   cas_write_latency                 cwlcov; 
   ddr2_additive_latency             d2_alcov;
   ddr3_additive_latency             d3_alcov; 
   sdram_density                     sdcov;  
   ddr2_sdram_cfg                    d2_sdcfgcov;
   ddr3_sdram_cfg                    d3_sdcfgcov;   
   rr_mode                           rrmcov;   
`ifdef DDR2  
   cov_address_ddr2                  add_ddr2cov;
`else 
   cov_address_ddr3                  add_ddr3cov;
`endif
   cov_ddr_sdram_inf_signals         ddr_sdram_inf_signalscov;   
   speed_grade                       sgcov; 
   wl_board_delays                   wl_board_dlycov;
   wl_board_delays_over_one_clock    wl_board_dly_over_one_clockcov;
   ac_bdl_dly_line_linearity         ac_bdl_dly_line_linearitycov;
   ac_mdl_dly_line_linearity         ac_mdl_dly_line_linearitycov;
   dx_bdl_r0_dly_line_linearity      dx_bdl_r0_dly_line_linearitycov;
   dx_bdl_r1_dly_line_linearity      dx_bdl_r1_dly_line_linearitycov;
   dx_bdl_r2_dly_line_linearity      dx_bdl_r2_dly_line_linearitycov;
   dx_bdl_r3_dly_line_linearity      dx_bdl_r3_dly_line_linearitycov;
   dx_bdl_r4_dly_line_linearity      dx_bdl_r4_dly_line_linearitycov;  
   dx_mdl_dly_line_linearity         dx_mdl_dly_line_linearitycov; 
   dx_lcdl_r0_dly_line_linearity     dx_lcdl_r0_dly_line_linearitycov;
   dx_lcdl_r1_dly_line_linearity     dx_lcdl_r1_dly_line_linearitycov;
   dx_lcdl_r2_dly_line_linearity     dx_lcdl_r2_dly_line_linearitycov;   
   ac_dly_line_osc_mode_time         ac_dly_line_osc_mode_timecov;
   dx_dly_line_osc_mode_time         dx_dly_line_osc_mode_timecov;
   clock_timing_mission_mode         clock_timing_mission_modecov ;
   clock_timing_bypass_mode          clock_timing_bypass_modecov ; 
   clock_timing_test_mode_bypass     clock_timing_test_mode_bypasscov ;
   AL_BL_CL_CWL_DDR3                 AL_BL_CL_CWL_ddr3cov;
   AL_BL_CL_CWL_DDR2                 AL_BL_CL_CWL_ddr2cov;
   d3_CL_nRCD_nRP                    d3_CL_nRCD_nRPcov;
   d2_CL_nRCD_nRP                    d2_CL_nRCD_nRPcov;
   data_channel_loopback             data_channel_loopbackcov;
   address_channel_loopback          addr_channel_loopbackcov;
   write_level_sl_encoding           write_level_sl_encodingcov;
   dqs_gating_scenario               dqs_gating_scenariocov;   
   ddrphy_engines                   ddrphy_enginescov;
   dqs_dq_drift                      dqs_dq_driftcov;
   dqs_dq_drift_scenario             dqs_dq_drift_scenariocov;
   dqs_dq_fixed_phase                dqs_dq_fixed_phasecov;
   vt_drift_w_dqs_dq_drift           vt_drift_w_dqs_dq_driftcov;
   vt_drift_w_wl                     vt_drift_w_wlcov;   
   data_lines_deskew                 data_lines_deskewcov;
   ddr2_memory_timing                ddr2_memory_timingcov;   
   ddr3_memory_timing                ddr3_memory_timingcov;
   
// test stimuli
   initial
     begin       
      $display("\n=> From the Functional Coverage.\n");   

       ////////////////////////////////////////
       ////////////////////////////////////////
       // Initialization of cover group objects
       ////////////////////////////////////////
       ////////////////////////////////////////      
       ddrmcov                              = new();
       dwmcov                               = new();
       zctrlcov                             = new(); 
       rankscov                             = new();       
       blcov                                = new();   
       d2_clcov                             = new();
       d3_clcov                             = new();
       cwlcov                               = new(); 
       d2_alcov                             = new();
       d3_alcov                             = new(); 
       //sdcov                                = new(); //Not used in regression script    
       rrmcov                               = new();        
`ifdef DDR2
       add_ddr2cov                          = new();       
`else
       add_ddr3cov                          = new();       
`endif
       sgcov                                = new();
       d2_sdcfgcov                          = new();
       d3_sdcfgcov                          = new();            
       wl_board_dlycov                      = new();
       wl_board_dly_over_one_clockcov       = new();
       ac_bdl_dly_line_linearitycov         = new();
       ac_mdl_dly_line_linearitycov         = new();
       dx_bdl_r0_dly_line_linearitycov      = new();
       dx_bdl_r1_dly_line_linearitycov      = new();
       dx_bdl_r2_dly_line_linearitycov      = new(); 
       dx_bdl_r3_dly_line_linearitycov      = new();
       dx_bdl_r4_dly_line_linearitycov      = new();
       dx_mdl_dly_line_linearitycov         = new();
       dx_lcdl_r0_dly_line_linearitycov     = new();
       dx_lcdl_r1_dly_line_linearitycov     = new();        
       dx_lcdl_r2_dly_line_linearitycov     = new();        
       //ac_dly_line_osc_mode_timecov         = new(); //Used with SDF
       //dx_dly_line_osc_mode_timecov         = new(); //Used with SDF
       clock_timing_mission_modecov         = new();
       clock_timing_bypass_modecov          = new(); 
       //clock_timing_test_mode_bypasscov     = new(); //Deactivated after Code review meeting , it is only used with ATPG
       AL_BL_CL_CWL_ddr3cov                 = new();       
       AL_BL_CL_CWL_ddr2cov                 = new();
       d3_CL_nRCD_nRPcov                    = new();
       d2_CL_nRCD_nRPcov                    = new();        
`ifdef DW_72
       data_channel_loopbackcov             = new();
       ddr_sdram_inf_signalscov             = new(); 
//`ifdef DDR3_8Gbx8   
       addr_channel_loopbackcov             = new();
//`endif        
`endif        
       write_level_sl_encodingcov           = new(); 
       dqs_gating_scenariocov               = new();      
       ddrphy_enginescov                   = new();
       dqs_dq_driftcov                      = new();
       dqs_dq_drift_scenariocov             = new(); 
       dqs_dq_fixed_phasecov                = new();
       vt_drift_w_dqs_dq_driftcov           = new();
       vt_drift_w_wlcov                     = new();  
       data_lines_deskewcov                 = new();
       //ddr2_memory_timingcov                = new(); //Not necessay for the DDRPHY
       //ddr3_memory_timingcov                = new(); //Not necessay for the DDRPHY
/////////////////////////////////////
/////////////////////////////////////
//Script options cover groups
/////////////////////////////////////
/////////////////////////////////////

// DDR mode        
`ifdef DDR2
     ddr_m = DDR2;
     ddrmcov.sample();   
`else
`ifdef DDR3        
     ddr_m = DDR3;
     ddrmcov.sample();
`else
     ddr_m = DDR3;
     ddrmcov.sample();
`endif        
`endif 

// Data width
`ifdef DW_8        
     dw_m = DW_8; 
     dwmcov.sample();            
`elsif  DW_16
     dw_m = DW_16;
     dwmcov.sample();             
`elsif  DW_24
     dw_m = DW_24;
     dwmcov.sample();          
`elsif  DW_32
     dw_m = DW_32;
     dwmcov.sample();         
`elsif  DW_40
     dw_m = DW_40;
     dwmcov.sample();           
`elsif  DW_48
     dw_m = DW_48;
     dwmcov.sample();         
`elsif  DW_56
     dw_m = DW_56;
     dwmcov.sample();                 
`elsif  DW_64
     dw_m = DW_64;
     dwmcov.sample();     
`elsif  DW_72
     dw_m = DW_72;
     dwmcov.sample();           
`endif     


//ZCtrl
  if (`DWC_NO_OF_ZQ == 4)              
     zctrl_m = MSD_ZCTRL_3; 
  else begin 
    if (`DWC_NO_OF_ZQ == 3)
       zctrl_m = MSD_ZCTRL_2; 
    else begin
      if (`DWC_NO_OF_ZQ == 2)
         zctrl_m = MSD_ZCTRL_1; 
      else begin
        if (`DWC_NO_OF_ZQ == 1)
          zctrl_m = MSD_ZCTRL_0;
      end
    end
  end
  zctrlcov.sample();  


//SDRAM Ranks
  if (`DWC_NO_OF_RANKS == 4)              
     ranks_m = NO_OF_RANKS_4; 
  else begin 
    if (`DWC_NO_OF_RANKS == 3)
       ranks_m = NO_OF_RANKS_3; 
    else begin
      if (`DWC_NO_OF_RANKS == 2)
         ranks_m = NO_OF_RANKS_2; 
      else begin
        if (`DWC_NO_OF_RANKS == 1)
          ranks_m = NO_OF_RANKS_1;
      end 
    end
  end
  rankscov.sample();  

 
// Burst length
`ifdef BL_4        
     bl_m = BL_4; 
     blcov.sample();            
`elsif  BL_8
     bl_m = BL_8;
     blcov.sample();             
`elsif  BL_V
     bl_m = BL_V;
     blcov.sample();              
`endif


// DDR2/DDR3 CAS Latency
//`ifdef CL_3        
//     d2_cl_m = d2_CL_3; 
//     d2_clcov.sample();            
//`elsif  CL_4
`ifdef  CL_4
     d2_cl_m = d2_CL_4;
     d2_clcov.sample();             
`elsif  CL_5
     d2_cl_m = d2_CL_5;
     d2_clcov.sample();
     d3_cl_m = d3_CL_5;
     d3_clcov.sample();         
`elsif  CL_6
     d2_cl_m = d2_CL_6;
     d2_clcov.sample();
     d3_cl_m = d3_CL_6;
     d3_clcov.sample();        
`elsif  CL_7
     d3_cl_m = d3_CL_7;
     d3_clcov.sample();             
`elsif  CL_8
     d3_cl_m = d3_CL_8;
     d3_clcov.sample();          
`elsif  CL_9
     d3_cl_m = d3_CL_9;
     d3_clcov.sample();
`elsif  CL_10
     d3_cl_m = d3_CL_10;
     d3_clcov.sample();             
`elsif  CL_11
     d3_cl_m = d3_CL_11;
     d3_clcov.sample();
`elsif  CL_12
     d3_cl_m = d3_CL_12;
     d3_clcov.sample();
`elsif  CL_13
     d3_cl_m = d3_CL_13;
     d3_clcov.sample();
`elsif  CL_14
     d3_cl_m = d3_CL_14;
     d3_clcov.sample();
`endif     
        

// CAS Write Latency
`ifdef CWL_5        
     cwl_m = CWL_5; 
     cwlcov.sample();                    
`elsif  CWL_6
     cwl_m = CWL_6;
     cwlcov.sample();   
`elsif  CWL_7
     cwl_m = CWL_7;
     cwlcov.sample();             
`elsif  CWL_8
     cwl_m = CWL_8;
     cwlcov.sample();               
`elsif  CWL_9
     cwl_m = CWL_9;
     cwlcov.sample();               
`elsif  CWL_10
     cwl_m = CWL_10;
     cwlcov.sample();               
`elsif  CWL_11
     cwl_m = CWL_11;
     cwlcov.sample();               
`elsif  CWL_12
     cwl_m = CWL_12;
     cwlcov.sample();               
`endif     
        

// DDR2/DDR3 Additive Latency
`ifdef AL_0        
     d2_al_m = d2_AL_0; 
     d2_alcov.sample();
     d3_al_m = d3_AL_0; 
     d3_alcov.sample();            
`elsif  AL_1
     d2_al_m = d2_AL_1;
     d2_alcov.sample();
     d3_al_m = d3_AL_1;
     d3_alcov.sample();        
`elsif  AL_2
     d2_al_m = d2_AL_2;
     d2_alcov.sample();
     d3_al_m = d3_AL_2;
     d3_alcov.sample();         
`elsif  AL_3
     d2_al_m = d2_AL_3;
     d2_alcov.sample();      
`elsif  AL_4
     d2_al_m = d2_AL_4;
     d2_alcov.sample();             
`elsif  AL_5
     d2_al_m = d2_AL_5;
     d2_alcov.sample();                    
`endif             


// SDRAM DENSITY
`ifdef M256        
     sd_m = M256; 
     //sdcov.sample();            
`elsif  M512
     sd_m = M512;
     //sdcov.sample();             
`elsif  M1024
     sd_m = M1024;
     //sdcov.sample();          
`elsif  M2048
     sd_m = M2048;
     //sdcov.sample();         
`elsif  M4096
     sd_m = M4096;
     //sdcov.sample();           
`elsif  M9192
     sd_m = M8192;
     //sdcov.sample();         
`endif                      

 
// SDRAM CONFIGURATION
`ifdef DDR2_256Mbx8
     d2_sdcfg_m = DDR2_256Mbx8;
     d2_sdcfgcov.sample();             
`elsif  DDR2_256Mbx16
     d2_sdcfg_m = DDR2_256Mbx16;
     d2_sdcfgcov.sample();                 
`elsif  DDR2_512Mbx8
     d2_sdcfg_m = DDR2_512Mbx8;
     d2_sdcfgcov.sample();           
`elsif  DDR2_512Mbx16
     d2_sdcfg_m = DDR2_512Mbx16;
     d2_sdcfgcov.sample();                      
`elsif  DDR2_1Gbx8
     d2_sdcfg_m = DDR2_1Gbx8;
     d2_sdcfgcov.sample();     
`elsif  DDR2_1Gbx16
     d2_sdcfg_m = DDR2_1Gbx16;
     d2_sdcfgcov.sample();                
`elsif  DDR2_2Gbx8
     d2_sdcfg_m = DDR2_2Gbx8;
     d2_sdcfgcov.sample();     
`elsif  DDR2_2Gbx16
     d2_sdcfg_m = DDR2_2Gbx16;
     d2_sdcfgcov.sample();              
`elsif  DDR2_4Gbx8
     d2_sdcfg_m = DDR2_4Gbx8;
     d2_sdcfgcov.sample();     
`elsif  DDR2_4Gbx16
     d2_sdcfg_m = DDR2_4Gbx16;
     d2_sdcfgcov.sample(); 
`elsif  DDR3_512Mbx8
     d3_sdcfg_m = DDR3_512Mbx8;
     d3_sdcfgcov.sample();           
`elsif  DDR3_512Mbx16
     d3_sdcfg_m = DDR3_512Mbx16;
     d3_sdcfgcov.sample(); 
`elsif  DDR3_1Gbx8        
     d3_sdcfg_m = DDR3_1Gbx8;
     d3_sdcfgcov.sample();     
`elsif  DDR3_1Gbx16
     d3_sdcfg_m = DDR3_1Gbx16;
     d3_sdcfgcov.sample();
`elsif  DDR3_2Gbx8
     d3_sdcfg_m = DDR3_2Gbx8;
     d3_sdcfgcov.sample();     
`elsif  DDR3_2Gbx16
     d3_sdcfg_m = DDR3_2Gbx16;
     d3_sdcfgcov.sample();
`elsif  DDR3_4Gbx8
     d3_sdcfg_m = DDR3_4Gbx8;
     d3_sdcfgcov.sample();     
`elsif  DDR3_4Gbx16
     d3_sdcfg_m = DDR3_4Gbx16;
     d3_sdcfgcov.sample(); 
`elsif  DDR3_8Gbx8
     d3_sdcfg_m = DDR3_8Gbx8;
     d3_sdcfgcov.sample();     
`elsif  DDR3_8Gbx16
     d3_sdcfg_m = DDR3_8Gbx16;
     d3_sdcfgcov.sample();           
`endif             
        
        
// RR Mode  
`ifdef DWC_DDRPHY_RR_MODE
     rr_m = MSD_RR_MODE;
     rrmcov.sample();
`else        
     rr_m = MSD_RF_MODE;
     rrmcov.sample();
`endif        


//DDR speed grade        
//`ifdef DDR2_533C        
//     speed_gr = DDR2_533C; 
//     sgcov.sample();
//     clock_timing_mission_modecov.sample(); 
//     AL_BL_CL_CWL_ddr2cov.sample(); 
//`elsif  DDR2_667C
`ifdef DDR2_667C
     speed_gr = DDR2_667C;
     sgcov.sample();
     clock_timing_mission_modecov.sample(); 
     AL_BL_CL_CWL_ddr2cov.sample();       
//`elsif  DDR2_400B
//     speed_gr = DDR2_400B;
//     sgcov.sample();
//     clock_timing_mission_modecov.sample(); 
//     AL_BL_CL_CWL_ddr2cov.sample();                    
`elsif  DDR2_800D
     speed_gr = DDR2_800D;
     sgcov.sample();  
     clock_timing_mission_modecov.sample(); 
     AL_BL_CL_CWL_ddr2cov.sample(); 
`elsif  DDR2_800E
     speed_gr = DDR2_800E;
     sgcov.sample();  
     clock_timing_mission_modecov.sample(); 
     AL_BL_CL_CWL_ddr2cov.sample();                          
`elsif  DDR3_800D
     speed_gr = DDR3_800D;
     sgcov.sample(); 
     clock_timing_mission_modecov.sample();
     AL_BL_CL_CWL_ddr3cov.sample();          
`elsif  DDR3_1066E
     speed_gr = DDR3_1066E;
     sgcov.sample();
     clock_timing_mission_modecov.sample();
     AL_BL_CL_CWL_ddr3cov.sample();            
`elsif  DDR3_1333F
     speed_gr = DDR3_1333F;
     sgcov.sample();
     clock_timing_mission_modecov.sample();
     AL_BL_CL_CWL_ddr3cov.sample();                 
`elsif  DDR3_1600G
     speed_gr = DDR3_1600G;
     sgcov.sample(); 
     clock_timing_mission_modecov.sample();
     AL_BL_CL_CWL_ddr3cov.sample();        
`elsif  DDR3_1866J
     speed_gr = DDR3_1866J;
     sgcov.sample(); 
     clock_timing_mission_modecov.sample();
     AL_BL_CL_CWL_ddr3cov.sample();        
`elsif  DDR3_2133K
     speed_gr = DDR3_2133K;
     sgcov.sample(); 
     clock_timing_mission_modecov.sample();
     AL_BL_CL_CWL_ddr3cov.sample();        
`endif     


    

    
     end // initial begin

`endif
   
////////////////////////////////////////
////////////////////////////////////////
// Tasks to set local params
////////////////////////////////////////
////////////////////////////////////////
   

//--------------------------------------------
// Task to set coverage on the memory address 
//--------------------------------------------
   
   task set_cov_address_param;      
   
      //input [`ADDR_WIDTH-1:0]       addri;   
      input [1:0]                   ranki;  
      input [2:0]                   banki;
      input [15:0]                  rowi;
      input [11:0]                  coli;
     begin
`ifdef FUNCOV      
      rank = ranki;
      bank = banki;
      row  = rowi;
      col  = coli;      
      sample_cov_address_param();
`endif
     end
      
   endtask // set_cov_address_param   

//--------------------------------------------   
// Task to sample the memory address   
//--------------------------------------------
  task sample_cov_address_param; 
     begin
`ifdef FUNCOV   
 `ifdef DDR2
     add_ddr2cov.sample();
 `else
     add_ddr3cov.sample();
 `endif       
`endif      
     end
   endtask // set_cov_address_param

//--------------------------------------------------------
// Task to set coverage on the DDR SDRAM interface signals
//--------------------------------------------------------
   
   task set_cov_ddr_sdram_inf_signals;     
         
      input                       ckei;       // SDRAM clock enable
      input                       odti;       // SDRAM on-die termination
      input                       cs_bi;      // SDRAM chip select
      input                       ras_bi;     // SDRAM row address select
      input                       cas_bi;     // SDRAM column address select
      input                       we_bi;      // SDRAM write enable
      input [`DWC_BANK_WIDTH-1:0] bai;        // SDRAM bank address
      input [`DWC_ADDR_WIDTH-1:0] ai;         // SDRAM address
      input [`DWC_NO_OF_BYTES-1:0] dmi;        // SDRAM output data mask
      input [`DWC_NO_OF_BYTES-1:0] dqsi;       // SDRAM input/output data strobe
      input [`DWC_NO_OF_BYTES-1:0] dqs_bi;     // SDRAM input/output data strobe #
      input [`DWC_DATA_WIDTH-1:0] dqi;        // SDRAM input/output data
     begin
`ifdef FUNCOV      
      cke    = ckei;      
      odt    = odti;      
      cs_b   = cs_bi;      
      ras_b  = ras_bi;      
      cas_b  = cas_bi;      
      we_b   = we_bi;      
      ba     = bai;      
      a      = ai;      
      dm     = dmi;      
      dqs    = dqsi;      
      dqs_b  = dqs_bi;      
      dq     = dqi;        
      sample_cov_ddr_sdram_inf_signals_param();
`endif
     end
   endtask // set_cov_ddr_sdram_inf_signals   
   

//--------------------------------------------   
// Task to sample the DDR SDRAM interface signals
//--------------------------------------------
  task sample_cov_ddr_sdram_inf_signals_param;
    begin
`ifdef FUNCOV
 `ifdef DW_72 
     ddr_sdram_inf_signalscov.sample();
 `endif       
`endif
    end
  endtask // sample_cov_ddr_sdram_inf_signals_param
   
    

//--------------------------------------------
// Task to set coverage on board delay
//--------------------------------------------   
   task set_cov_board_dly_param;
         
      input integer     board_dlyi;
     begin
`ifdef FUNCOV
      board_dly = board_dlyi;
      sample_cov_board_dly_param();  
`endif
     end
   endtask // set_cov_board_dly_param

//--------------------------------------------   
// Task to sample the board delay  
//--------------------------------------------  
   task sample_cov_board_dly_param;
     begin
`ifdef FUNCOV      
      wl_board_dlycov.sample();
`endif    
     end
   endtask // sample_cov_board_dly_param

//-------------------------------------------------------------
// Task to set coverage on  DQS/DQ Drift scenarios coverage
//-------------------------------------------------------------   
   task set_cov_dqs_dq_drift_scenario;
     
      input integer      dqs_dq_drift_scni;          
      
     begin
`ifdef FUNCOV    
       case(dqs_dq_drift_scni)
        `DQS_DQ_DRIFT_INC       :     dqs_dq_drift_scn  = INCREMENT_DQS_DQ_DRIFT_10PS;       
        `DQS_DQ_DRIFT_DEC       :     dqs_dq_drift_scn  = DECREMENT_DQS_DQ_DRIFT_10PS;  
        `DQS_DQ_DRIFT_RANDOM    :     dqs_dq_drift_scn  = RANDOM_DQS_DQ_DRIFT;            
      endcase       
      sample_cov_dqs_dq_drift_scenario_param();      
`endif     
     end
   endtask // set_cov_dqs_dq_drift_scenario
   
              
//-------------------------------------------------
// Task to sample the DQS/DQ  Drift scenarios
//-------------------------------------------------   
   task sample_cov_dqs_dq_drift_scenario_param;      
     begin
`ifdef FUNCOV      
      dqs_dq_drift_scenariocov.sample(); 
`endif          
     end
   endtask // sample_cov_dqs_dq_drift_scenario_param
     


//-------------------------------------------------------------
// Task to set coverage on  VT Drift with DQS/DQ Drift coverage
//-------------------------------------------------------------   
   task set_cov_vt_drift_w_dqs_dq_drift;

      input integer      vt_dqs_dqi;           
      input integer      dqs_dq_drift_vi;
      
     begin
`ifdef FUNCOV    
       case(vt_dqs_dqi)
        `VT_DRIFT_W_DQS_DQ_DRIFT_INC      :     vt_dqs_dq  = VT_DRIFT_W_DQS_DQ_DRIFT_INCREMENTAL;       
        `VT_DRIFT_W_DQS_DQ_DRIFT_RND      :     vt_dqs_dq  = VT_DRIFT_W_DQS_DQ_DRIFT_RANDOM;          
       endcase // case (vt_dqs_dqi)
               
       dqs_dq_drift_v = dqs_dq_drift_vi; 
       sample_cov_vt_drift_w_dqs_dq_drift_param();      
`endif     
     end
   endtask // set_cov_vt_drift_w_dqs_dq_drift
   
   
              
//----------------------------------------------------------------
// Task to sample the VT drift and DQS/DQ  Drift and scenario type
//----------------------------------------------------------------   
   task sample_cov_vt_drift_w_dqs_dq_drift_param;      
     begin
`ifdef FUNCOV      
      vt_drift_w_dqs_dq_driftcov.sample(); 
`endif          
     end
   endtask // sample_cov_vt_drift_w_dqs_dq_drift_param
   


  
 //-------------------------------------------------------------
// Task to set coverage on  VT Drift with WL coverage
//-------------------------------------------------------------   
   task set_cov_vt_drift_w_wl;

      input integer      vt_wli;           
      input integer      wl_vi;
      
     begin
`ifdef FUNCOV    
       case(vt_wli)       
        `VT_DRIFT_W_WL_INC :  vt_wl = VT_DRIFT_W_WL_INCREMENTAL;         
        `VT_DRIFT_W_WL_RND :  vt_wl = VT_DRIFT_W_WL_RANDOM;
         
       endcase // case (vt_wli)        
               
       wl_v = wl_vi; 
       //sample_cov_vt_drift_w_wl_param();      
`endif     
     end
   endtask // set_cov_vt_drift_w_wl
   
      
              
//----------------------------------------------------------------
// Task to sample the VT drift and WL and scenario type
//----------------------------------------------------------------   
   task sample_cov_vt_drift_w_wl_param;      
     begin
`ifdef FUNCOV      
      vt_drift_w_wlcov.sample(); 
`endif          
     end
   endtask // sample_cov_vt_drift_w_wl_param
   
   
    
//-------------------------------------------------------------
// Task to set coverage on  DQS/DQ fixed phased  coverage
//-------------------------------------------------------------   
   task set_cov_dqs_dq_fixed_phase;
     
      input integer      dqs_dq_fixed_phasei;          
      
     begin
`ifdef FUNCOV    
       case(dqs_dq_fixed_phasei)
        `DQS_DQ_PHASED_POS_QUARTER      :     dqs_dq_phased   = DQS_DQ_POS_PHASED_QUARTER_CLOCK;       
        `DQS_DQ_PHASED_POS_HALF         :     dqs_dq_phased   = DQS_DQ_POS_PHASED_HALF_CLOCK;  
        `DQS_DQ_PHASED_POS_3QUARTERS    :     dqs_dq_phased   = DQS_DQ_POS_PHASED_THREE_QUARTER_CLOCK;            
        `DQS_DQ_PHASED_POS_FULL         :     dqs_dq_phased   = DQS_DQ_POS_PHASED_FULL_CLOCK;  
        `DQS_DQ_PHASED_NEG_QUARTER      :     dqs_dq_phased   = DQS_DQ_NEG_PHASED_QUARTER_CLOCK;       
        `DQS_DQ_PHASED_NEG_HALF         :     dqs_dq_phased   = DQS_DQ_NEG_PHASED_HALF_CLOCK;  
        `DQS_DQ_PHASED_NEG_3QUARTERS    :     dqs_dq_phased   = DQS_DQ_NEG_PHASED_THREE_QUARTER_CLOCK;            
        `DQS_DQ_PHASED_NEG_FULL         :     dqs_dq_phased   = DQS_DQ_NEG_PHASED_FULL_CLOCK;
      endcase       
      sample_cov_dqs_dq_fixed_phased_param();      
`endif     
     end
   endtask // set_cov_dqs_dq_fixed_phase

              
//-------------------------------------------------
// Task to sample the DQS/DQ fixed phases
//-------------------------------------------------   
   task sample_cov_dqs_dq_fixed_phased_param;      
     begin
`ifdef FUNCOV      
      dqs_dq_fixed_phasecov.sample(); 
`endif          
     end
   endtask // sample_cov_dqs_dq_fixed_phased_param
   
   
//--------------------------------------------
// Task to set coverage on DQS/DQ drift
//--------------------------------------------   
   task set_cov_dqs_dq_drift_param;
         
      input integer     dqs_dq_dfti;
     begin
`ifdef FUNCOV
      if(dqs_dq_dfti <=640)  
         dqs_dq_dft_first_half_range = dqs_dq_dfti;
      else
         dqs_dq_dft_second_half_range = dqs_dq_dfti;  
      sample_cov_dqs_dq_drift_param();  
`endif
     end
   endtask // set_cov_dqs_dq_drift_param
   
   
//--------------------------------------------   
// Task to sample the DQS/DQ drift
//--------------------------------------------  
   task sample_cov_dqs_dq_drift_param;
     begin
`ifdef FUNCOV      
      dqs_dq_driftcov.sample();
`endif    
     end
   endtask // sample_cov_dqs_dq_drift_param
       

//---------------------------------------------------------
// Task to set coverage on board delay over one SDRAM Clock
//---------------------------------------------------------      
   task set_cov_board_dly_over_one_clock_param;
     
      input integer     board_dly_over_one_clocki;
     begin
`ifdef FUNCOV
      board_dly_over_one_clock = board_dly_over_one_clocki;
      sample_cov_board_dly_over_one_clock_param();
`endif    
     end
   endtask // set_cov_board_dly_over_one_clock_param


//---------------------------------------------------------
// Task to sample board delay over one SDRAM Clock
//---------------------------------------------------------   
   task sample_cov_board_dly_over_one_clock_param;
     begin
`ifdef FUNCOV      
      wl_board_dly_over_one_clockcov.sample(); 
`endif    
     end
   endtask // sample_cov_board_dly_over_one_clock_param   


//------------------------------------------------------
// Task to set coverage on AC BDL for linearity coverage
//------------------------------------------------------
   task set_cov_ac_bdl_dly_line_linearity;
     
      input reg [`REG_ADDR_WIDTH:0]       reg_addr;
      input reg[5:0]      ACBDLi;      
      input integer       index;
     begin
`ifdef FUNCOV
      case(index)
        0: ACBDL_CK0BD = ACBDLi;
        1: ACBDL_CK1BD = ACBDLi;
        2: ACBDL_CK2BD = ACBDLi;
        3: ACBDL_ACBD  = ACBDLi;    
      endcase // case (index)                  
      sample_cov_ac_bdl_dly_line_linearity_param();
`endif    
     end  
   endtask // set_cov_ac_bdl_dly_line_linearity

//-------------------------------------------------
// Task to sample the AC BDL for linearity coverage
//-------------------------------------------------
   task sample_cov_ac_bdl_dly_line_linearity_param;
     begin
`ifdef FUNCOV      
      ac_bdl_dly_line_linearitycov.sample();  
`endif     
     end  
   endtask // sample_cov_ac_bdl_dly_line_linearity_param

//------------------------------------------------------
// Task to set coverage on AC MDL for linearity coverage
//------------------------------------------------------   
   task set_cov_ac_mdl_dly_line_linearity;
     
      input reg [`REG_ADDR_WIDTH:0]       reg_addr;
      input reg[7:0]      ACMDLDi;      
      input integer       index;
     begin
`ifdef FUNCOV
      case(index)
        0: ACMDLD = ACMDLDi;        
      endcase // case (index)
                  
      sample_cov_ac_mdl_dly_line_linearity_param();
`endif      
     end
   endtask // set_cov_ac_mdl_dly_line_linearity


//-------------------------------------------------
// Task to sample the AC MDL for linearity coverage
//-------------------------------------------------   
   task sample_cov_ac_mdl_dly_line_linearity_param;
     begin
`ifdef FUNCOV      
      ac_mdl_dly_line_linearitycov.sample();  
`endif         
     end
   endtask // sample_cov_ac_mdl_dly_line_linearity_param
   
 
//---------------------------------------------------------------------
// Task to set coverage on DX BDL R0/R1/R2/R3/R4 for linearity coverage
//--------------------------------------------------------------------
   task set_cov_dx_bdl_dly_line_linearity;

      input reg [`REG_ADDR_WIDTH:0]       reg_addr;
      input reg[5:0]      DXBDLi;      
      input integer       index;
     begin
`ifdef FUNCOV
      case(reg_addr)
        `DX0BDLR0:
          begin
            case(index)
              0: DQ0WBD  = DXBDLi;
              1: DQ1WBD  = DXBDLi;
              2: DQ2WBD  = DXBDLi;
              3: DQ3WBD  = DXBDLi;
              4: DQ4WBD  = DXBDLi;
            endcase // case (index)
          end
        `DX0BDLR1:
          begin
            case(index)
              0: DQ5WBD  = DXBDLi;
              1: DQ6WBD  = DXBDLi;
              2: DQ7WBD  = DXBDLi;
              3: DMWBD   = DXBDLi;
              4: DSWBD   = DXBDLi;
            endcase // case (index)
          end
        `DX0BDLR2:
          begin
            case(index)
              0: DSOEBD  = DXBDLi;
              1: DQOEBD  = DXBDLi;
              2: DSRBD   = DXBDLi;
              3: DSNRBD  = DXBDLi;
            endcase // case (index)
          end
        `DX0BDLR3:
          begin
            case(index)
              0: DQ0RBD  = DXBDLi;
              1: DQ1RBD  = DXBDLi;
              2: DQ2RBD  = DXBDLi;
              3: DQ3RBD  = DXBDLi;
              4: DQ4RBD  = DXBDLi;
            endcase // case (index)
          end
        `DX0BDLR4:
          begin
            case(index)
              0: DQ5RBD  = DXBDLi;
              1: DQ6RBD  = DXBDLi;
              2: DQ7RBD  = DXBDLi;
              3: DMRBD   = DXBDLi;
            endcase // case (index)
          end
      endcase // case (reg_addr)
      
      sample_cov_dx_bdl_dly_line_linearity_param(reg_addr);  
`endif  
     end
   endtask // set_cov_ac_bdl_dly_line_linearity

//----------------------------------------------------------------
// Task to sample the DX BDL R0/R1/R2/R3/R4 for linearity coverage
//----------------------------------------------------------------
   task sample_cov_dx_bdl_dly_line_linearity_param;
      input reg [`REG_ADDR_WIDTH:0]       reg_addr;
     begin
`ifdef FUNCOV
      case(reg_addr)
        `DX0BDLR0: dx_bdl_r0_dly_line_linearitycov.sample();  
        `DX0BDLR1: dx_bdl_r1_dly_line_linearitycov.sample();
        `DX0BDLR2: dx_bdl_r2_dly_line_linearitycov.sample();
        `DX0BDLR3: dx_bdl_r3_dly_line_linearitycov.sample();
        `DX0BDLR4: dx_bdl_r4_dly_line_linearitycov.sample();
      endcase // case (reg_addr) 
`endif                           
     end
   endtask // sample_cov_dx_bdl_dly_line_linearity_param
   

//------------------------------------------------------
// Task to set coverage on DX MDL for linearity coverage
//------------------------------------------------------   
   task set_cov_dx_mdl_dly_line_linearity;

      input reg [`REG_ADDR_WIDTH:0]       reg_addr;
      input reg[7:0]      DXMDLDi;      
      input integer       index;
     begin
`ifdef FUNCOV
      case(index)
        0: DXMDLD = DXMDLDi;        
      endcase // case (index)
                  
      sample_cov_dx_mdl_dly_line_linearity_param();
`endif     
     end
   endtask // set_cov_dx_mdl_dly_line_linearity


//-------------------------------------------------
// Task to sample the DX MDL for linearity coverage
//-------------------------------------------------   
   task sample_cov_dx_mdl_dly_line_linearity_param;
     begin
`ifdef FUNCOV      
      dx_mdl_dly_line_linearitycov.sample(); 
`endif          
     end
   endtask // sample_cov_dx_mdl_dly_line_linearity_param


//------------------------------------------------------
// Task to set coverage on DX LCDL R0 for linearity coverage
//------------------------------------------------------
   task set_cov_dx_lcdl_dly_line_linearity;

      input reg [`REG_ADDR_WIDTH:0]       reg_addr;
      input reg[7:0]      DXLCDLi;      
      input integer       index;
     begin
`ifdef FUNCOV
      case(reg_addr)
        `DX0LCDLR0:
          begin
            case(index)
              0: R0WLD  = DXLCDLi;
              1: R1WLD  = DXLCDLi;
              2: R2WLD  = DXLCDLi;
              3: R3WLD  = DXLCDLi;
            endcase // case (index)
          end
        `DX0LCDLR1:
          begin
            case(index)
              0: WDQD   = DXLCDLi;
              1: RDQSD  = DXLCDLi;
              2: RDQSND = DXLCDLi;

            endcase // case (index)
          end
        `DX0LCDLR2:
          begin
            case(index)
              0: R0DQSGD  = DXLCDLi;
              1: R1DQSGD  = DXLCDLi;
              2: R2DQSGD  = DXLCDLi;
              3: R3DQSGD  = DXLCDLi;
            endcase // case (index)
          end
      endcase // case (reg_addr)
      
      sample_cov_dx_lcdl_dly_line_linearity_param(reg_addr);   
`endif 
     end
   endtask // set_cov_dx_lcdl_dly_line_linearity
   

//-------------------------------------------------
// Task to sample the DX LCDL for linearity coverage
//-------------------------------------------------
   task sample_cov_dx_lcdl_dly_line_linearity_param;
      input reg [`REG_ADDR_WIDTH:0]       reg_addr;
     begin
`ifdef FUNCOV
      case(reg_addr)
        `DX0LCDLR0: dx_lcdl_r0_dly_line_linearitycov.sample();  
        `DX0LCDLR1: dx_lcdl_r1_dly_line_linearitycov.sample();
        `DX0LCDLR2: dx_lcdl_r2_dly_line_linearitycov.sample();
      endcase // case (reg_addr) 
`endif           
     end
   endtask // sample_cov_dx_lcdl_dly_line_linearity_param


 
//-------------------------------------------------------------
// Task to set coverage on AC delay line oscillator mode timing
//-------------------------------------------------------------   
   task set_cov_ac_dly_line_osc_mode_time;

      input integer       timehi;
      input integer       timelo;
      input integer       timeperiod;
     begin
`ifdef FUNCOV
      
       
`ifdef FAST_SDF
      output_osc_hi_pulse_min_max = timehi;   
      output_osc_lo_pulse_min_max = timelo;      
      output_osc_period_min_max = timeperiod;
      sample_cov_ac_dly_line_osc_mode_time_param();
`else      
`ifdef TYPICAL_SDF
      output_osc_hi_pulse_min_max = timehi;   
      output_osc_lo_pulse_min_max = timelo;      
      output_osc_period_min_max = timeperiod; 
      sample_cov_ac_dly_line_osc_mode_time_param();
`else
`ifdef SLOW_SDF
      output_osc_hi_pulse_min_max = timehi;   
      output_osc_lo_pulse_min_max = timelo;      
      output_osc_period_min_max = timeperiod;
      sample_cov_ac_dly_line_osc_mode_time_param();     
`endif      
`endif      
`endif                            
      
`endif     
     end
   endtask // set_cov_ac_dly_line_osc_mode_time   


//-------------------------------------------------
// Task to sample the AC delay line oscillator timing
//-------------------------------------------------   
   task sample_cov_ac_dly_line_osc_mode_time_param;      
     begin
`ifdef FUNCOV      
      ac_dly_line_osc_mode_timecov.sample(); 
`endif          
     end
   endtask // sample_cov_ac_dly_line_osc_mode_time_param
   


//-------------------------------------------------------------
// Task to set coverage on DX delay line oscillator mode timing
//-------------------------------------------------------------   
   task set_cov_dx_dly_line_osc_mode_time;

      input integer       timehi;
      input integer       timelo;
      input integer       timeperiod;
     begin
`ifdef FUNCOV
             
`ifdef FAST_SDF
      output_osc_hi_pulse_min_max = timehi;   
      output_osc_lo_pulse_min_max = timelo;      
      output_osc_period_min_max = timeperiod;      
      sample_cov_dx_dly_line_osc_mode_time_param();
`else      
`ifdef TYPICAL_SDF
      output_osc_hi_pulse_min_max = timehi;   
      output_osc_lo_pulse_min_max = timelo;      
      output_osc_period_min_max = timeperiod;      
      sample_cov_dx_dly_line_osc_mode_time_param();
`else
`ifdef SLOW_SDF
      output_osc_hi_pulse_min_max = timehi;   
      output_osc_lo_pulse_min_max = timelo;      
      output_osc_period_min_max = timeperiod; 
      sample_cov_dx_dly_line_osc_mode_time_param();      
`endif      
`endif      
`endif                            
      
`endif     
     end
   endtask // set_cov_dx_dly_line_osc_mode_time   


//-------------------------------------------------
// Task to sample the DX delay line oscillator timing
//-------------------------------------------------   
   task sample_cov_dx_dly_line_osc_mode_time_param; 
     begin
`ifdef FUNCOV      
      dx_dly_line_osc_mode_timecov.sample(); 
`endif          
     end
   endtask // sample_cov_dx_dly_line_osc_mode_time_param



//-------------------------------------------------------------
// Task to set coverage on PLL bypass enable
//-------------------------------------------------------------   
   task set_cov_pll_bypass_en;

      input reg       pll_bypass_eni;

     begin
`ifdef FUNCOV   
      pll_bypass_en =  pll_bypass_eni;                     
      sample_cov_pll_bypass_en_param();      
`endif     
     end
   endtask // set_cov_pll_bypass_en   


//-------------------------------------------------
// Task to sample the PLL bypass clock timing mode
//-------------------------------------------------   
   task sample_cov_pll_bypass_en_param;      
     begin
`ifdef FUNCOV      
      clock_timing_bypass_modecov.sample(); 
`endif          
     end
   endtask // sample_cov_pll_bypass_en_param


//-------------------------------------------------------------
// Task to set coverage on Test Mode bypass enable
//-------------------------------------------------------------   
   task set_cov_test_mode_bypass_en;

      input reg       test_mode_bypass_eni;

     begin
`ifdef FUNCOV   
      test_mode_bypass_en =  test_mode_bypass_eni;                     
      sample_cov_pll_test_mode_bypass_en_param();      
`endif     
     end
   endtask // set_cov_test_mode_bypass_en
     

//-------------------------------------------------
// Task to sample the Test mode bypass clock timing
//-------------------------------------------------   
   task sample_cov_pll_test_mode_bypass_en_param;      
     begin
`ifdef FUNCOV      
      clock_timing_test_mode_bypasscov.sample(); 
`endif          
     end
   endtask // sample_cov_pll_test_mode_bypass_en_param      
        

//-------------------------------------------------------------
// Task to set coverage on CL-nRCD-nRP
//-------------------------------------------------------------   
   task set_cov_cl_nrcd_nrp;      

      input integer       CLi;
      input integer       nrcdi;
      input integer       nrpi;
     begin
      
`ifdef FUNCOV   
      CL   = CLi;
      nRCD = nrcdi;
      nRP  = nrpi;
      
      sample_cov_cl_nrcd_nrp_param();      
`endif     
     end
   endtask // set_cov_cl_nrcd_nrp
   
     

//-------------------------------------------------
// Task to sample the CL , nRCD and the nRP parameters
//-------------------------------------------------   
   task sample_cov_cl_nrcd_nrp_param;      
     begin
`ifdef FUNCOV
`ifdef DDR2
     d2_CL_nRCD_nRPcov.sample();
`else
`ifdef DDR3        
     d3_CL_nRCD_nRPcov.sample();
`else
     d3_CL_nRCD_nRPcov.sample();
`endif        
`endif       

`endif          
     end
   endtask // sample_cov_cl_nrcd_nrp_param
   

//-------------------------------------------------------------
// Task to set coverage on data channel loopback
//-------------------------------------------------------------   
   task set_cov_data_channel_loopback;      

      input reg [`DWC_DATA_WIDTH-1:0]      data_ch_lbi;
      input integer                        beat;
      input integer                        pattern_typei;
     begin
`ifdef FUNCOV
      case(beat)
        0:
          begin
            data_ch_lb_beat0 = data_ch_lbi;            
          end
        1:
          begin
            data_ch_lb_beat1 = data_ch_lbi;
          end
        2:
          begin
            data_ch_lb_beat2 = data_ch_lbi;
          end
        3:
          begin
            data_ch_lb_beat3 = data_ch_lbi;
          end        
      endcase // case (index)
      case (pattern_typei)
       0:
         begin
            pattern_type = WALKING_ONES;
         end
       1:
         begin
            pattern_type = WALKING_ZEROS;            
         end
       2:
         begin
            pattern_type = TOGGLE_DATA_ZEROS_AND_ONES;            
         end
       3:
         begin
            pattern_type = TOGGLE_DATA_As_AND_5s;            
         end
       4:
         begin
            pattern_type = RANDOM_DATA;            
         end                
      endcase
    
      
      sample_cov_data_channel_loopback_param();      
`endif     
     end
   endtask // set_cov_data_channel_loopback
           

//-------------------------------------------------
// Task to sample the data channel loopback information
//-------------------------------------------------   
   task sample_cov_data_channel_loopback_param;  
    
     begin
`ifdef FUNCOV
     `ifdef DW_72
       data_channel_loopbackcov.sample();
      `endif  
`endif          
     end
   endtask // sample_cov_data_channel_loopback_param
   

//-------------------------------------------------------------
// Task to set coverage on addr channel loopback
//-------------------------------------------------------------   
   task set_cov_addr_channel_loopback;      

      input reg [15:0]          addr_ch_lbi;      
      
     begin
`ifdef FUNCOV

        addr_ch_lb = addr_ch_lbi;                      
      
        sample_cov_addr_channel_loopback_param();      
`endif     
     end
   endtask // set_cov_addr_channel_loopback
           

//-------------------------------------------------
// Task to sample the addr channel loopback information
//-------------------------------------------------   
   task sample_cov_addr_channel_loopback_param;  
    
     begin
`ifdef FUNCOV
`ifdef DW_72
//       `ifdef DDR3_8Gbx8         
          addr_channel_loopbackcov.sample();
//       `endif 
`endif
        
`endif          
     end
   endtask // sample_cov_addr_channel_loopback_param

   
//-------------------------------------------------------------
// Task to set coverage on  write level select encoding
//-------------------------------------------------------------   
   task set_cov_write_level_sl_encoding;

      input reg          sl_enc_typei;
      input reg [1:0]    wl_seli;
      input integer      wl_delayi;
      
     begin
`ifdef FUNCOV   
      case(sl_enc_typei)
        0:
          begin
            sl_enc_type = TYPE_I;
          end
        1:
          begin
            sl_enc_type = TYPE_II;
          end          

      endcase // case (sl_enc_typei)
      case(wl_delayi)
        0: wl_delay = BETWEEN_0_90; 
        1: wl_delay = BETWEEN_90_270;        
        2: wl_delay = BETWEEN_270_450;        
        3: wl_delay = BETWEEN_0_135;        
        4: wl_delay = BETWEEN_135_315;        
        5: wl_delay = BETWEEN_315_495;        
      endcase // case (wl_delayi)
      case(wl_seli)
        2'b00: wl_sel = WL_SEL_00;       
        2'b01: wl_sel = WL_SEL_01;        
        2'b10,2'b11: wl_sel = WL_SEL_1X;  
      endcase        
        
      sample_cov_write_level_sl_encoding_param();      
`endif     
     end
   endtask // set_cov_write_level_sl_encoding
   
     

//-------------------------------------------------
// Task to sample the  write level select encoding
//-------------------------------------------------   
   task sample_cov_write_level_sl_encoding_param;      
     begin
`ifdef FUNCOV      
      write_level_sl_encodingcov.sample(); 
`endif          
     end
   endtask // sample_cov_write_level_sl_encoding_param   


//-------------------------------------------------------------
// Task to set coverage on  DQS Gating scenarios coverage
//-------------------------------------------------------------   
   task set_cov_dqs_gating_scenario;
     
      input integer      dqs_gating_scni;     
      
     begin
`ifdef FUNCOV    
      case(dqs_gating_scni)
        0:     dqs_gating_scn = INCREMENTAL_DXnLCDLR2_10PS;       
        1:     dqs_gating_scn = DECREMENTAL_DXnLCDLR2_10PS;  
        2,3,4: dqs_gating_scn = RANDOM_DXnLCDLR2_10PS;         
      endcase       
      sample_cov_dqs_gating_scenario_param();      
`endif     
     end
   endtask // set_cov_dqs_gating_scenario
           

//-------------------------------------------------
// Task to sample the DQS Gating scenarios
//-------------------------------------------------   
   task sample_cov_dqs_gating_scenario_param;      
     begin
`ifdef FUNCOV      
      dqs_gating_scenariocov.sample(); 
`endif          
     end
   endtask // sample_cov_dqs_gating_scenario_param     
   
//-------------------------------------------------------------
// Task to set coverage on DDR3 PHY Engines
//-------------------------------------------------------------   
   task set_cov_ddrphy_engines;
     
      input integer      ddrphy_enginesi;     
      
     begin
`ifdef FUNCOV    
       case(ddrphy_enginesi)
         `DQSG_SCN: ddrphy_engine = DQS_GATING;         
         `WL_SCN  : ddrphy_engine = WRITE_LEVELING;         
         `VT_SCN  : ddrphy_engine = VT_DRIFTING;         
         `DQSD_SCN: ddrphy_engine = DQS_DRIFTING;         
      endcase       
      sample_cov_ddrphy_engines_param();      
`endif     
     end
   endtask // set_cov_ddrphy_engines
         

//-------------------------------------------------
// Task to sample the  DDR3 PHY Engines
//-------------------------------------------------   
   task sample_cov_ddrphy_engines_param;      
     begin
`ifdef FUNCOV      
      ddrphy_enginescov.sample(); 
`endif          
     end
   endtask // sample_cov_ddrphy_engines_param
   

//--------------------------------------------
// Task to set write coverage on all registers
//--------------------------------------------
   task set_cov_dly_line_registers;       
      input [`REG_ADDR_WIDTH-1:0] reg_addr;
      input [`REG_DATA_WIDTH-1:0] reg_value;
      input    [1:0]              select;      
    begin
`ifdef FUNCOV   
      case(reg_addr)

            `ACBDLR: begin 
                case(select)
                  0:begin  
                     ACBDLR_CK0BD_5_0 = reg_value[5:0];
                     ACBDLR_CK1BD_11_6 = reg_value[11:6];
                     ACBDLR_CK2BD_17_12 = reg_value[17:12];   
                     ACBDLR_ACBD_23_18 = reg_value[23:18];
                  end
                endcase // case (select)               
            end                
            `DX0BDLR0: begin 
                case(select)
                  0:begin
                     DX0BDLR0_DQ0WBD_5_0 = reg_value[5:0];
                     DX0BDLR0_DQ1WBD_11_6 = reg_value[11:6];
                     DX0BDLR0_DQ2WBD_17_12 = reg_value[17:12];
                     DX0BDLR0_DQ3WBD_23_18 = reg_value[23:18];
                     DX0BDLR0_DQ4WBD_29_24 = reg_value[29:24];                     
                  end
                endcase // case (select)               
            end             
            `DX0BDLR1: begin 
                case(select)
                  0:begin
                     DX0BDLR1_DQ5WBD_5_0 = reg_value[5:0];
                     DX0BDLR1_DQ6WBD_11_6 = reg_value[11:6];
                     DX0BDLR1_DQ7WBD_17_12 = reg_value[17:12];
                     DX0BDLR1_DMWBD_23_18 = reg_value[23:18];
                     DX0BDLR1_DSWBD_29_24 = reg_value[29:24];   
                  end
                endcase // case (select)               
            end              
            `DX0BDLR2: begin 
                case(select)
                  0:begin
                     DX0BDLR2_DSOEBD_5_0 = reg_value[5:0];
                     DX0BDLR2_DQOEBD_11_6 = reg_value[11:6];                     
                     DX0BDLR2_DSRBD_17_12 = reg_value[17:12];                     
                     DX0BDLR2_DSNRBD_23_18 = reg_value[23:18];                     
                  end
                endcase // case (select)               
            end             
            `DX0BDLR3: begin 
                case(select)
                  0:begin
                     DX0BDLR3_DQ0RBD_5_0 = reg_value[5:0];
                     DX0BDLR3_DQ1RBD_11_6 = reg_value[11:6];
                     DX0BDLR3_DQ2RBD_17_12 = reg_value[17:12];
                     DX0BDLR3_DQ3RBD_23_18 = reg_value[23:18];
                     DX0BDLR3_DQ4RBD_29_24 = reg_value[29:24];                     
                  end
                endcase // case (select)               
            end                 
            `DX0BDLR4: begin 
                case(select)
                  0:begin
                     DX0BDLR4_DQ5RBD_5_0 = reg_value[5:0];
                     DX0BDLR4_DQ6RBD_11_6 = reg_value[11:6];
                     DX0BDLR4_DQ7RBD_17_12 = reg_value[17:12];
                     DX0BDLR4_DMRBD_23_18 = reg_value[23:18];
                  end
                endcase // case (select)               
            end             
            `DX0LCDLR0: begin 
                case(select)
                  0:begin
                     DX0LCDLR0_R0WLD_7_0 = reg_value[7:0];
                     DX0LCDLR0_R1WLD_15_8 = reg_value[15:8];   
                     DX0LCDLR0_R2WLD_23_16 = reg_value[23:16];
                     DX0LCDLR0_R3WLD_31_24 = reg_value[31:24];                      
                  end
                endcase // case (select)               
            end             
            `DX0LCDLR1: begin 
                case(select)
                  0:begin
                     DX0LCDLR1_WDQD_7_0 = reg_value[7:0];
                     DX0LCDLR1_RDQSD_15_8 = reg_value[15:8];  
                     DX0LCDLR1_RDQSND_23_16 = reg_value[23:16];
                  end
                endcase // case (select)               
            end             
            `DX0LCDLR2: begin 
                case(select)
                  0:begin
                     DX0LCDLR2_R0DQSGD_7_0 = reg_value[7:0];
                     DX0LCDLR2_R1DQSGD_15_8 = reg_value[15:8];   
                     DX0LCDLR2_R2DQSGD_23_16 = reg_value[23:16];
                     DX0LCDLR2_R3DQSGD_31_24 = reg_value[31:24];                     
                  end
                endcase // case (select)               
            end                
            `DX0MDLR: begin 
                case(select)
                  0:begin
                     //DX0MDLR_IPRD_7_0 = reg_value[7:0];
                     DX0MDLR_TPRD_15_8 = reg_value[15:8];
                     DX0MDLR_MDLD_23_16 = reg_value[23:16];                      
                  end
                endcase // case (select)               
            end             
      endcase // case (reg_addr)
           
`endif //  `ifdef FUNCOV
    end   
      
   endtask // endtask   
      

//-------------------------------------------------------------
// Task to set read and write deskew coverage
//-------------------------------------------------------------   
   task set_cov_data_deskew_lines;

      input integer           deskew_datai;
      input integer           select;      
      input integer           devicei; 
   
     begin
`ifdef FUNCOV 
       case(select)
           `WRITE_DATA_DESKEW:begin
               write_data = deskew_datai; 
           end
           `READ_DATA_DESKEW:begin
               read_data =  deskew_datai;
           end
       endcase // case (select)
       device = devicei;
       sample_cov_data_deskew_lines_param();      
`endif     
     end
   endtask // set_cov_data_deskew_lines
     

//-------------------------------------------------
// Task to sample the data deskew lines
//-------------------------------------------------   
   task sample_cov_data_deskew_lines_param;      
     begin
`ifdef FUNCOV      
      data_lines_deskewcov.sample(); 
`endif          
     end
   endtask // sample_cov_data_deskew_lines_param


   
//-------------------------------------------------------------
// Task to set memory timing parameters
//-------------------------------------------------------------   
   task set_cov_memory_timing_param;
   
      input reg [2:0]                  t_orwl_oddi;
      input reg [`tMRD_WIDTH:0]        t_mrdi;      // load mode to load mode 
      input reg [`tRP_WIDTH-1:0]       t_rpi;       // precharge to activate
      input reg [`tRRD_WIDTH-1:0]      t_rrdi;      // activate to activate (diff banks)
      input reg [`tRC_WIDTH-1:0]       t_rci;       // activate to activate
      input reg [`tFAW_WIDTH-1:0]      t_fawi;      // 4-bank active window
      input reg [`tRFC_WIDTH-1:0]      t_rfci;      // refresh to refresh (min)
      input reg [tRP_WIDTH-1:0]        t_pre2acti;
      input reg [tACT2RW_WIDTH-1:0]    t_act2rwi;
      input reg [tRD2PRE_WIDTH-1:0]    t_rd2prei;
      input reg [tWR2PRE_WIDTH-1:0]    t_wr2prei;
      input reg [tRD2WR_WIDTH-1:0]     t_rd2wri;
      input reg [tWR2RD_WIDTH-1:0]     t_wr2rdi;
      input reg [tRD2PRE_WIDTH-1:0]    t_rdap2acti;
      input reg [tWR2PRE_WIDTH-1:0]    t_wrap2acti;    
     begin
`ifdef FUNCOV 
        t_orwl_odd = t_orwl_oddi;
        t_mrd      = t_mrdi;
        t_rp       = t_rpi;
        t_rrd      = t_rrdi;
        t_rc       = t_rci;
        t_faw      = t_fawi;
        t_rfc      = t_rfci;
        t_pre2act  = t_pre2acti;
        t_act2rw   = t_act2rwi;
        t_rd2pre   = t_rd2prei;
        t_wr2pre   = t_wr2prei;
        t_rd2wr    = t_rd2wri;
        t_wr2rd    = t_wr2rdi;
        t_rd2wr    = t_rd2wri;
        t_wr2rd    = t_wr2rdi;
        t_rdap2act = t_rdap2acti;
        t_wrap2act = t_wrap2acti;                   
        sample_cov_memory_timing_param();      
`endif     
     end
   endtask // set_cov_memory_timing_param
   
     

//-------------------------------------------------
// Task to sample the memory timing parameters
//-------------------------------------------------   
   task sample_cov_memory_timing_param;      
     begin
`ifdef FUNCOV 
 `ifdef DDR2
      ddr2_memory_timingcov.sample();
 `else
  `ifdef DDR3        
      ddr3_memory_timingcov.sample();
  `else
      ddr3_memory_timingcov.sample();
  `endif        
 `endif 
`endif          
     end
   endtask // sample_cov_memory_timing_param
         
endmodule // ddr_fcov
