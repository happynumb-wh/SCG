//-----------------------------------------------------------------------------
//
// Copyright (c) 2010 Synopsys Incorporated.				   
// 									   
// This file contains confidential, proprietary information and trade	   
// secrets of Synopsys. No part of this document may be used, reproduced   
// or transmitted in any form or by any means without prior written	   
// permission of Synopsys Incorporated. 				   
// 
// DESCRIPTION: DDR PHY BIST verification testcases common routines
//-----------------------------------------------------------------------------
// PUB Data Train common utilities (dt_common.v)
//-----------------------------------------------------------------------------
//
  


//---------------------------------------------------------------------------
// Tasks
//---------------------------------------------------------------------------
/*
  task ;
    input reg [pDTRPTN_WIDTH-1:0 ]    	dtrptn_reg;
    input reg [pDTRNK_WIDTH-1:0  ]    	dtrank_reg;
    input reg [pDTMPR_WIDTH-1:0  ]    	dtmpr_reg;
    input reg [pDTCMPD_WIDTH-1:0 ]    	dtcmpd_reg;
    input reg [pDTWDQM_WIDTH-1:0]       dtwdqm_reg;
    input reg [pDTWBDDM_WIDTH-1:0]    	dtwbddm_reg;
    input reg [pDTDBS_WIDTH-1:0  ]    	dtdbs_reg;
    input reg [pDTDEN_WIDTH-1:0  ]    	dtden_reg;
    input reg [pDTDSTP_WIDTH-1:0 ]    	dtdstp_reg;
    input reg [pDTEXG_WIDTH-1:0  ]    	dtexg_reg;
    input reg [pRANKEN_WIDTH-1:0 ]    	dtranken_reg;
    input reg [pRFSHDT_WIDTH-1:0 ]    	rfshdt_reg;  
                   reg [31:0]     tmp;
    begin
      // write DTCR
      tmp = `GRM.dtcr;
      tmp[pDTRPTN_TO_BIT : pDTRPTN_FROM_BIT]  = dtrptn_reg  ;
      tmp[pDTRNK_TO_BIT  : pDTRNK_FROM_BIT]   = dtrank_reg  ;
      tmp[pDTMPR_TO_BIT  : pDTMPR_FROM_BIT]   = dtmpr_reg   ;
      tmp[pDTCMPD_TO_BIT : pDTCMPD_FROM_BIT]  = dtcmpd_reg  ;
      tmp[pDTWDQM_TO_BIT : pDTWDQM_FROM_BIT]  = dtwdqm_reg  ;
      tmp[pDTWBDDM_TO_BIT: pDTWBDDM_FROM_BIT] = dtwbddm_reg ;
      tmp[pDTDBS_TO_BIT  : pDTDBS_FROM_BIT]   = dtdbs_reg   ;
      tmp[pDTDEN_TO_BIT  : pDTDEN_FROM_BIT]   = dtden_reg   ;
      tmp[pDTDSTP_TO_BIT : pDTDSTP_FROM_BIT]  = dtdstp_reg  ;
      tmp[pDTEXG_TO_BIT  : pDTEXG_FROM_BIT]   = dtexg_reg   ;
      tmp[pRANKEN_TO_BIT : pRANKEN_FROM_BIT]  = dtranken_reg;
      tmp[pRFSHDT_TO_BIT : pRFSHDT_FROM_BIT]  = rfshdt_reg  ;
            
      // write DTAR0-3

      // write DTDR0-1

      // write PIR
      
    end
  endtask // set_dt_wr_dt_eye
*/

  task set_dtar0;
    input reg [pDTCOL_WIDTH-1:0 ]				col_reg;
    input reg [pDTROW_WIDTH-1:0 ]				row_reg;
    input reg [pDTBANK_WIDTH-1:0]				bank_reg;
    reg [31:0]     tmp;
    begin
      tmp = `GRM.dtar0;
      tmp[pDTROW_TO_BIT :pDTROW_FROM_BIT ]  = row_reg;
      tmp[pDTBANK_TO_BIT:pDTBANK_FROM_BIT]  = bank_reg;
      `CFG.write_register(`DTAR0, tmp);
      `FCOV_REG.set_cov_registers_write(`DTAR0,tmp,`VALUE_REGISTER_DATA);                 
  
      // COL0 field is in DTAR1
      tmp = `GRM.dtar1;
      tmp[pDTCOL0_TO_BIT:pDTCOL0_FROM_BIT]  = col_reg[pDTCOL_WIDTH-1:3];
      `CFG.write_register(`DTAR1, tmp);
      `FCOV_REG.set_cov_registers_write(`DTAR1,tmp,`VALUE_REGISTER_DATA);                 
    end
  endtask // set_dtar0

  task set_dtar1;
    input reg [pDTCOL_WIDTH-1:0 ]				col_reg;
    input reg [pDTROW_WIDTH-1:0 ]				row_reg;
    input reg [pDTBANK_WIDTH-1:0]				bank_reg;
    reg [31:0]     tmp;
    begin
      tmp = `GRM.dtar1;
      tmp[pDTCOL1_TO_BIT :pDTCOL1_FROM_BIT] = col_reg[pDTCOL_WIDTH-1:3];
      `CFG.write_register(`DTAR1, tmp);
      `FCOV_REG.set_cov_registers_write(`DTAR1,tmp,`VALUE_REGISTER_DATA);                 
    end
  endtask // set_dtar1

  task set_dtar2;
    input reg [pDTCOL_WIDTH-1:0 ]				col_reg;
    input reg [pDTROW_WIDTH-1:0 ]				row_reg;
    input reg [pDTBANK_WIDTH-1:0]				bank_reg;
    reg [31:0]     tmp;
    begin
      tmp = `GRM.dtar2;
      tmp[pDTCOL2_TO_BIT :pDTCOL2_FROM_BIT] = col_reg[pDTCOL_WIDTH-1:3];
      `CFG.write_register(`DTAR2, tmp);
      `FCOV_REG.set_cov_registers_write(`DTAR2,tmp,`VALUE_REGISTER_DATA);                 
    end
  endtask // set_dtar2

  task set_dtdr0;
    input reg [7:0]                     dt_byte0;
    input reg [7:0]                     dt_byte1;
    input reg [7:0]                     dt_byte2;
    input reg [7:0]                     dt_byte3;
    reg [31:0]     tmp;
 
    begin
      tmp = {dt_byte3, dt_byte2, dt_byte1, dt_byte0};
      `CFG.write_register(`DTDR0, tmp);
      `FCOV_REG.set_cov_registers_write(`DTDR0,tmp,`VALUE_REGISTER_DATA);                 
    end
  endtask // set_dtdr0


  task set_dtdr1;
    input reg [7:0]                     dt_byte0;
    input reg [7:0]                     dt_byte1;
    input reg [7:0]                     dt_byte2;
    input reg [7:0]                     dt_byte3;
    reg [31:0]     tmp;
 
    begin
      tmp = {dt_byte3, dt_byte2, dt_byte1, dt_byte0};
      `CFG.write_register(`DTDR1, tmp);
      `FCOV_REG.set_cov_registers_write(`DTDR1,tmp,`VALUE_REGISTER_DATA);                 
    end
  endtask // set_dtdr1



  task set_dt_wr_rd_dteye;
    input reg [pDTRPTN_WIDTH-1:0 ]    	dtrptn_reg;
    input reg [pDTRNK_WIDTH-1:0  ]    	dtrank_reg;
    input reg [pDTMPR_WIDTH-1:0  ]    	dtmpr_reg;
    input reg [pDTCMPD_WIDTH-1:0 ]    	dtcmpd_reg;
    input reg [pDTWDQM_WIDTH-1:0]     	dtwdqm_reg;
    input reg [pDTWBDDM_WIDTH-1:0]    	dtwbddm_reg;    
    
    input reg [pDTEXD_WIDTH-1:0  ]    	dtexd_reg;
    input reg [pDTBDC_WIDTH-1:0  ]    	dtbdc_reg;
    input reg [pDTDBS_WIDTH-1:0  ]    	dtdbs_reg;
    input reg [pDTDEN_WIDTH-1:0  ]    	dtden_reg;
    input reg [pDTDSTP_WIDTH-1:0 ]    	dtdstp_reg;

    input reg [pRFSHDT_WIDTH-1:0]       rfshdt_reg;
    input reg                           dt_wl_enable;
    input reg                           dt_rdqsg_enable;
    input reg                           dt_wladj_enable;

    input reg                           dt_rd_bskw_enable;
    input reg                           dt_wr_bskw_enable;
    input reg                           dt_rd_dteye_enable;
    input reg                           dt_wr_dteye_enable;
    
               
    reg [31:0]     tmp;
    begin
      // write DTCR
      tmp = `GRM.dtcr0;
      tmp[pDTRPTN_TO_BIT : pDTRPTN_FROM_BIT]  = dtrptn_reg;
      tmp[pDTRNK_TO_BIT  : pDTRNK_FROM_BIT]   = dtrank_reg;
      tmp[pDTMPR_TO_BIT  : pDTMPR_FROM_BIT]   = dtmpr_reg;
      tmp[pDTCMPD_TO_BIT : pDTCMPD_FROM_BIT]  = dtcmpd_reg;
      tmp[pDTWDQM_TO_BIT: pDTWDQM_FROM_BIT]   = dtwdqm_reg;
      tmp[pDTWBDDM_TO_BIT: pDTWBDDM_FROM_BIT] = dtwbddm_reg;
      
      // write DTCR ; for debug
      tmp[pDTBDC_TO_BIT  : pDTBDC_FROM_BIT]   = dtbdc_reg;
      tmp[pDTEXD_TO_BIT  : pDTEXD_FROM_BIT]   = dtexd_reg;
      tmp[pDTDBS_TO_BIT  : pDTDBS_FROM_BIT]   = dtdbs_reg;
      tmp[pDTDEN_TO_BIT  : pDTDEN_FROM_BIT]   = dtden_reg;
      tmp[pDTDSTP_TO_BIT : pDTDSTP_FROM_BIT]  = dtdstp_reg;
      tmp[pRFSHDT_TO_BIT : pRFSHDT_FROM_BIT]  = rfshdt_reg;

      $display ("\n-> %0t: [BENCH] -------------------------------------------------------------------", $time);
      if (dt_wr_bskw_enable == 1'b1)
        $display ("-> %0t: [BENCH] DTCR with rank %0d in DT WR Bit Deskew mode", $time, dtrank_reg);
      if (dt_rd_bskw_enable == 1'b1)
        $display ("-> %0t: [BENCH] DTCR with rank %0d in DT RD Bit Deskew mode", $time, dtrank_reg);
      if (dt_wr_dteye_enable == 1'b1)
        $display ("-> %0t: [BENCH] DTCR with rank %0d in DT WR EYE mode", $time, dtrank_reg);
      if (dt_rd_dteye_enable == 1'b1)
        $display ("-> %0t: [BENCH] DTCR with rank %0d in DT RD EYE mode", $time, dtrank_reg);
  
      $display ("-> %0t: [BENCH] dtrptn_reg = %0h", $time, dtrptn_reg);
      $display ("-> %0t: [BENCH] dtrank_reg = %0h", $time, dtrank_reg);
      $display ("-> %0t: [BENCH] dtmpr_reg  = %0h", $time, dtmpr_reg);
      $display ("-> %0t: [BENCH] dtcmpd_reg = %0h", $time, dtcmpd_reg);
      $display ("-> %0t: [BENCH] dtwdqm_reg = %0h", $time, dtwdqm_reg);

      $display ("-> %0t: [BENCH] dtbdc_reg  = %0h", $time, dtbdc_reg);
      $display ("-> %0t: [BENCH] dtexd_reg  = %0h", $time, dtexd_reg);
      $display ("-> %0t: [BENCH] dtdbs_reg  = %0h", $time, dtdbs_reg);
      $display ("-> %0t: [BENCH] dtden_reg  = %0h", $time, dtden_reg);
      $display ("-> %0t: [BENCH] dtdstp_reg = %0h", $time, dtdstp_reg);
      $display ("-> %0t: [BENCH] rfshdt_reg = %0h", $time, rfshdt_reg);
      $display ("-> %0t: [BENCH] ---------------------------------------------------------------------", $time);
      
      `CFG.write_register(`DTCR0, tmp);
      `FCOV_REG.set_cov_registers_write(`DTCR0,tmp,`VALUE_REGISTER_DATA);  
      `FCOV_REG.set_cov_data_eye_train_cfg_scenario;
      `FCOV_REG.set_cov_data_eye_train_debug_scenario;
      
      if (dt_rd_bskw_enable || dt_wr_bskw_enable || dt_rd_dteye_enable || dt_wr_dteye_enable)
        `SYS.data_eye_training = 1'b1;
  
      
      // write PIR
      tmp = `GRM.pir;
      tmp[0]  = `TRUE;
      tmp[9]  = dt_wl_enable;
      tmp[10] = dt_rdqsg_enable;
      tmp[11] = dt_wladj_enable;
      
      tmp[12] = dt_rd_bskw_enable;
      tmp[13] = dt_wr_bskw_enable;
      tmp[14] = dt_rd_dteye_enable;
      tmp[15] = dt_wr_dteye_enable;
      `CFG.write_register(`PIR, tmp);
      `FCOV_REG.set_cov_registers_write(`PIR,tmp,`VALUE_REGISTER_DATA);           
      
    end
  endtask // set_dt_wr_rd_dteye


  task set_dt_data_register_rnd;
    reg [31:0]     tmp1,tmp2;
    begin
      tmp1 = {$random};
      tmp2 = {$random};
      $display ("\n-> %0t: [BENCH] -------------------------------------------------------------------", $time);
      $display ("-> %0t: [BENCH] DTBYTE0 = %0h", $time, tmp1[ 7:0]);
      $display ("-> %0t: [BENCH] DTBYTE1 = %0h", $time, tmp1[15:8]);
      $display ("-> %0t: [BENCH] DTBYTE2 = %0h", $time, tmp1[23:16]);
      $display ("-> %0t: [BENCH] DTBYTE3 = %0h", $time, tmp1[31:24]);
      $display ("-> %0t: [BENCH] DTBYTE4 = %0h", $time, tmp2[ 7:0]);
      $display ("-> %0t: [BENCH] DTBYTE5 = %0h", $time, tmp2[15:8]);
      $display ("-> %0t: [BENCH] DTBYTE6 = %0h", $time, tmp2[23:16]);
      $display ("-> %0t: [BENCH] DTBYTE7 = %0h", $time, tmp2[31:24]);
      $display ("\n-> %0t: [BENCH] -------------------------------------------------------------------", $time);

      `CFG.write_register(`DTDR0, tmp1);
      `FCOV_REG.set_cov_registers_write(`DTDR0,tmp1,`VALUE_REGISTER_DATA);           
      `CFG.write_register(`DTDR1, tmp2);
      `FCOV_REG.set_cov_registers_write(`DTDR1,tmp2,`VALUE_REGISTER_DATA);           
    end
  endtask // set_dt_data_register_rnd


  task set_dt_addr_register_rnd;
    reg [pDTCOL_WIDTH-1:0]     tmp_col;
    reg [pDTROW_WIDTH-1:0]     tmp_row;
    reg [pDTBANK_WIDTH-1:0]    tmp_bank;
    reg [31:0]                 tmp;
    reg [3:0]                  rnd_ratio;
    reg [pDTCOL_WIDTH-1:0]     rnd_col;
    
    begin
      tmp_bank = {$random};    // bank has to be same for all 4 address
      tmp_row  = {$random};    // row has to be same for all 4 address
      rnd_col  = {$random};    
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 1, 15, rnd_ratio[3:0]);  // want col to be all different

      for (i=0; i<4;i=i+1) begin
        tmp = 32'h0;
        tmp_col = rnd_col + 12'h008*i*rnd_ratio;
        tmp_col[2:0] = 3'b000;
                
        $display ("\n-> %0t: [BENCH] -------------------------------------------------------------------", $time);
        $display ("-> %0t: [BENCH]       rnd_ratio = %0h", $time, rnd_ratio);
        $display ("-> %0t: [BENCH] DTAR%0d.DTCOL  = %0h", $time, i, tmp_col [pDTCOL_WIDTH-1:0]);
        $display ("-> %0t: [BENCH] DTAR%0d.DTROW  = %0h", $time, i, tmp_row [pDTROW_WIDTH-1:0]);
        $display ("-> %0t: [BENCH] DTAR%0d.DTBANK = %0h", $time, i, tmp_bank[pDTBANK_WIDTH-1:0]);
        $display ("\n-> %0t: [BENCH] -------------------------------------------------------------------", $time);
        tmp = {tmp_bank, tmp_row, tmp_col};
        `CFG.write_register(`DTAR0+8'h1*i, tmp);
        `FCOV_REG.set_cov_registers_write(`DTAR0+8'h1*i,tmp,`VALUE_REGISTER_DATA);           
        end
      end
    endtask // set_dt_addr_register_rnd


  task check_data_trained_status;
    input reg                           dt_wl_done;
    input reg                           dt_dqs_gate_done;
    input reg                           dt_wl_adj_done;
    input reg                           dt_rd_b_dskw_done;
    input reg                           dt_wr_b_dskw_done;
    input reg                           dt_rd_eye_done;
    input reg                           dt_wr_eye_done;
    
    input reg                           dt_wl_err;
    input reg                           dt_dqs_gate_err;
    input reg                           dt_wl_adj_err;
    input reg                           dt_rd_bskw_err;
    input reg                           dt_wr_bskw_err;
    input reg                           dt_rd_dteye_err;
    input reg                           dt_wr_dteye_err; 

    reg [31:0]                          tmp;
    integer i;
    begin

      `GRM.pgsr0[5]  = dt_wl_done;       
      `GRM.pgsr0[6]  = dt_dqs_gate_done; 
      `GRM.pgsr0[7]  = dt_wl_adj_done;
      `GRM.pgsr0[8]  = dt_rd_b_dskw_done;   
      `GRM.pgsr0[9]  = dt_wr_b_dskw_done;
      `GRM.pgsr0[10] = dt_rd_eye_done;   
      `GRM.pgsr0[11] = dt_wr_eye_done;   

      `GRM.pgsr0[21] = dt_wl_err;        
      `GRM.pgsr0[22] = dt_dqs_gate_err;  
      `GRM.pgsr0[23] = dt_wl_adj_err; 
      `GRM.pgsr0[24] = dt_rd_bskw_err;    
      `GRM.pgsr0[25] = dt_wr_bskw_err;
      `GRM.pgsr0[26] = dt_rd_dteye_err;    
      `GRM.pgsr0[27] = dt_wr_dteye_err;    
      
      `CFG.disable_read_compare;
      `CFG.read_register_data(`PGSR0, tmp);
      if ((tmp[27:0]) != (`GRM.pgsr0[27:0])) begin
        `SYS.error;
        $display("-> %0t: [DT_COMMON] ERROR: Comparing PGSR0[27:0]. Expected PGSR0[27:0] = %0h but got %0h instead.  VALUES mismatch!!!", $time, `GRM.pgsr0[27:0], tmp[27:0]);
      end

      for (i=0;i<`ALL_BYTES;i=i+1) begin
         tmp = `GRM.dtcr0;
         tmp[19:16] = i[3:0];
         `CFG.write_register(`DTCR0, tmp);
         `FCOV_REG.set_cov_registers_write(`DTCR0,tmp,`VALUE_REGISTER_DATA);           
   
         `CFG.read_register_data(`DTEDR0, tmp);
         if (i<`BYTE_WIDTH) begin
           if (dt_wr_dteye_err == 1'b0) begin
             // TBD:check the calculation for the WDQ register
           end
           `CFG.read_register_data(`DTEDR1, tmp);
           if (dt_rd_dteye_err == 1'b0) begin
             // TBD:check the calculation for the RDQS register
           end
         end
      end
  
      repeat (2) @(posedge `CFG.clk);      
      `CFG.enable_read_compare;
      
      `ifdef PROBE_DATA_EYES
          //if (`CLK_PRD != 1.25)  `EYE_MNT.ensure_dl_step_scaled ;
          if ( `EYE_MNT.expected_dl_step_value == 0.0 ) `EYE_MNT.update_dl_step_value("RD","DQ","BDL");   //all DL steps should be identical!
          repeat (1000) @(posedge `CFG.clk);
         if (`GRM.pgsr0[27:24]==4'b0000) begin //no errors in DT
           `EYE_MNT.get_eye_plots(-1,ddr_tb.last_bank) ; 
           `EYE_MNT.check_training_status(1'b0) ;
         end  
         repeat (1000) @(posedge `CFG.clk); 
      `endif
    
    end
  endtask // check_data_trained_status


  task set_dt_dqs_gate;
    begin
    end
  endtask // set_dt_dqs_gate


  function [3:0] random_dtrptn;
    input     dummy;
    reg [3:0] tmp;
    begin
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 15, tmp);
      random_dtrptn = tmp;
    end
  endfunction

  function [1:0] random_dtrank;
    input     dummy;
    reg [1:0] tmp;
    begin
      tmp = {$random} % `DWC_NO_OF_RANKS;
      random_dtrank = tmp;
    end
  endfunction

  function random_dtmpr;
    input     dummy;
    reg       tmp;
    begin
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 1, tmp);
      random_dtmpr = tmp;
    end
  endfunction

  function random_dtcmpd;
    input     dummy;
    reg       tmp;
    begin
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 1, tmp);
      random_dtcmpd = tmp;
    end
  endfunction

  function [3:0] random_dtwdqm;
    input     dummy;
    reg [3:0] tmp;
    begin
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 15, tmp);
      random_dtwdqm = tmp;
    end
  endfunction

  function random_dtwbddm;
    input     dummy;
    reg       tmp;
    begin
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 1, tmp);
      random_dtwbddm = tmp;
    end
  endfunction

  function [3:0] random_dtdbs;
    input     dummy;
    reg [3:0] tmp;
    begin
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 15, tmp);
      random_dtdbs = tmp;
    end
  endfunction

  function random_dtden;
    input     dummy;
    reg       tmp;
    begin
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 1, tmp);
      random_dtden = tmp;
    end
  endfunction

  function random_dtdstp;
    input     dummy;
    reg       tmp;
    begin
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 1, tmp);
      random_dtdstp = tmp;
    end
  endfunction

  function random_dtexg;
    input     dummy;
    reg       tmp;
    begin
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 1, tmp);
      random_dtexg = tmp;
    end
  endfunction

  function random_dtexd;
    input     dummy;
    reg       tmp;
    begin
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 1, tmp);
      random_dtexd = tmp;
    end
  endfunction

  function [3:0] random_ranken;
    input     dummy;
    reg [3:0] tmp;
    begin
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 15, tmp);
      random_ranken = tmp;
    end
  endfunction

  function [3:0] random_rfshdt;
    input     dummy;
    reg [3:0] tmp;
    begin
      `ifdef LPDDR2
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 7, tmp);
      `elsif LPDDR3
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 7, tmp);
      `else
      `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 15, tmp);
      `endif
      random_rfshdt = tmp;
    end
  endfunction

//--------------------------------------------------------------------------- 
// generate random wait time within given range
//--------------------------------------------------------------------------- 
function integer random_range;
  input   integer    min;
  input   integer    max;
  integer            tmp;
  begin
    // make sure there's a valid value for seed_rr
    if(`SYS.seed_rr === 'hx) begin
      $display("[ERROR] Illegal value for `SYS.seed_rr, `SYS.seed = %0d", `SYS.seed_rr);
      `SYS.error;
    end

    `SYS.RANDOM_RANGE(`SYS.seed_rr, min, max, tmp);
    random_range = tmp;
  end
endfunction

//--------------------------------------------------------------------------- 
// generate random wait time within MIN_WAIT and MAX_WAIT
//--------------------------------------------------------------------------- 
function integer random_wait_clk;
  input      dummy;
  begin
    random_wait_clk = random_range(MIN_WAIT_CLK, MAX_WAIT_CLK);
    $display("-> %0t: [DT_COMMON] wait %0d clocks before insert error",$time, random_wait_clk);
  end
endfunction


/*
      set_dt_wr_rd_dteye (random_dtrptn(0), random_dtrank(0),
                          random_dtmpr(0),  random_dtcmpd(0),
                          random_dtwdqm(0),
                          0,0,0,
                          //random_dtdbs(0), random_dtden(0), random_dtdstp(0),
                          dt_wr_dteye_reg, dt_rd_dteye_reg);
*/ 

//--------------------------------------------------------------------------- 
// generate random WLSTEP setting but consider the WLPRD period
//  - using WLSTEP=0 (32 taps) could result in an incorrect WL delay value (extra period added)
//--------------------------------------------------------------------------- 
task set_wl_step_rnd;
  reg [31:0]     tmp1,tmp2;
  real realtmp;
  integer k;
  begin
    
    // find the smallest wlprd
    for (k=0;k<`DWC_NO_OF_BYTES;k=k+1)
      begin
        `CFG.read_register_data(`DX0GSR0 + `DX_REG_RANGE*k, tmp1);
        if (k == 0) begin
          tmp2 = tmp1[14:7];
        end else begin 
          if (tmp1[14:7] < tmp2)
            tmp2 = tmp1[14:7];
        end
      end
    
    // to ensure WL works (including jitter) we want to wlprd to be about a 3:1 ratio to the WLSTEP
    realtmp = tmp2/32.0;
    if (realtmp >= 3.0 )
      `GRM.pgcr1[2] = {$random} % 2;          // WLSTEP
    else
      `GRM.pgcr1[2] = 1;  // force WLSTEP to 1 tap

    @(posedge `CFG.clk);
    `CFG.write_register(`PGCR1, `GRM.pgcr1);
    `FCOV_REG.set_cov_registers_write(`PGCR1,`GRM.pgcr1,`VALUE_REGISTER_DATA);

end
endtask // wl_step_rnd


