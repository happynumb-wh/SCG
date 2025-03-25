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
// PUB Bist on DX (bist_common.v)
//-----------------------------------------------------------------------------
//

                                    // LSB    a      cs_n, cke       MSB
localparam   pLPDDR2_PATTERN_WIDTH = 10 + (`DWC_NO_OF_RANKS * 2);
                                    // LSB    a      cs_n, cke, odt  MSB
localparam   pLPDDR3_PATTERN_WIDTH = 10 + (`DWC_NO_OF_RANKS * 3);

// Indices for each AC signal within the wide pattern bus
// LPDDR Modes
`ifdef LPDDRX
  localparam   pAC_POS_FIELD_A_LO     = 0
  ,            pAC_POS_FIELD_A_HI     = pAC_POS_FIELD_A_LO     + 10 - 1
  ,            pAC_POS_FIELD_CSN_LO   = pAC_POS_FIELD_A_HI     + 1
  ,            pAC_POS_FIELD_CSN_HI   = pAC_POS_FIELD_CSN_LO   + `DWC_NO_OF_RANKS - 1
  ,            pAC_POS_FIELD_CKE_LO   = pAC_POS_FIELD_CSN_HI   + 1
  ,            pAC_POS_FIELD_CKE_HI   = pAC_POS_FIELD_CKE_LO   + `DWC_NO_OF_RANKS - 1
  ,            pAC_POS_FIELD_ODT_LO   = pAC_POS_FIELD_CKE_HI   + 1
  ,            pAC_POS_FIELD_ODT_HI   = pAC_POS_FIELD_ODT_LO   + `DWC_NO_OF_RANKS - 1
  ;
// DDRn Modes
`else
  localparam   pAC_POS_FIELD_A_LO     = 0
  ,            pAC_POS_FIELD_A_HI     = pAC_POS_FIELD_A_LO     + `PUB_ADDR_WIDTH - 1
  ,            pAC_POS_FIELD_CSN_LO   = pAC_POS_FIELD_A_HI     + 1
  ,            pAC_POS_FIELD_CSN_HI   = pAC_POS_FIELD_CSN_LO   + `DWC_NO_OF_RANKS - 1
  ,            pAC_POS_FIELD_CKE_LO   = pAC_POS_FIELD_CSN_HI   + 1
  ,            pAC_POS_FIELD_CKE_HI   = pAC_POS_FIELD_CKE_LO   + `DWC_NO_OF_RANKS - 1
  ,            pAC_POS_FIELD_BA_LO    = pAC_POS_FIELD_CKE_HI   + 1
  ,            pAC_POS_FIELD_BA_HI    = pAC_POS_FIELD_BA_LO    + `DWC_BANK_WIDTH - 1
  ,            pAC_POS_FIELD_RASN_LO  = pAC_POS_FIELD_BA_HI    + 1  // Same as ACT_n
  ,            pAC_POS_FIELD_RASN_HI  = pAC_POS_FIELD_RASN_LO  + 1 - 1
  ,            pAC_POS_FIELD_ODT_LO   = pAC_POS_FIELD_RASN_HI  + 1
  ,            pAC_POS_FIELD_ODT_HI   = pAC_POS_FIELD_ODT_LO   + `DWC_NO_OF_RANKS - 1
  ,            pAC_POS_FIELD_PARITY_LO   = pAC_POS_FIELD_ODT_HI   + 1
  ,            pAC_POS_FIELD_PARITY_HI   = pAC_POS_FIELD_PARITY_LO + 1 - 1
  ;
`endif

//--------------------------------------------------------------------------- 
// Common variables
//--------------------------------------------------------------------------- 

integer                     total_bist_pattern_width;
reg                         force_err_pattern_on;

//--------------------------------------------------------------------------- 
// Common setup
//--------------------------------------------------------------------------- 

initial begin
  force_err_pattern_on = 0;
  #1;
  total_bist_pattern_width  = (`GRM.lpddr2_mode == 1) ? pLPDDR2_PATTERN_WIDTH : 
                              (`GRM.lpddr3_mode == 1) ? pLPDDR3_PATTERN_WIDTH :
                                                        TOTAL_AC_PATTERN_WIDTH;
end

//--------------------------------------------------------------------------- 
// generate random valid bcksel and bccsel
//--------------------------------------------------------------------------- 
function [1:0] random_bcksel;
  input     dummy;
  reg [1:0] tmp;
  begin
    case (`DWC_CK_WIDTH)
      1: tmp = 0;
      2: tmp = 0 + {$random} % 2;
      3: tmp = 0 + {$random} % 3;
      default: tmp = 0;
    endcase // case(`DWC_CK_WIDTH)
    random_bcksel = tmp;
  end
endfunction

function [1:0] random_bccsel;
  input     dummy;
  reg [1:0] tmp;
  begin
    tmp = 0 + {$random} % 4;
    random_bccsel = tmp;
  end
endfunction


//--------------------------------------------------------------------------- 
// generate random bdxsel     
//--------------------------------------------------------------------------- 
function [3:0] random_bdxsel;
  input       dummy;
  reg [3:0]   tmp;
  begin
    tmp = {$random} % `DWC_NO_OF_BYTES;
    random_bdxsel = tmp;
  end
endfunction

//--------------------------------------------------------------------------- 
// generate random bsonf 
//--------------------------------------------------------------------------- 
function [0:0] random_bsonf;
  input       dummy;
  reg         tmp;
  begin
    tmp = {$random};
    random_bsonf = tmp;
  end
endfunction

//--------------------------------------------------------------------------- 
// generate random nfail to stop, pick a range from 0 to 2
//--------------------------------------------------------------------------- 
function [7:0] random_nfail_0_2;
  input       dummy;
  reg [7:0]   tmp;
  begin
    tmp = {$random} % 3;
    random_nfail_0_2 = tmp;
  end
endfunction

//--------------------------------------------------------------------------- 
// generate random nfail to stop, pick a range from 0 to 20
//--------------------------------------------------------------------------- 
function [7:0] random_nfail_0_20;
  input       dummy;
  reg [7:0]   tmp;
  begin
    tmp = {$random} % 21;
    random_nfail_0_20 = tmp;
  end
endfunction

//--------------------------------------------------------------------------- 
// Generate random nfail to stop, pick a range from 0 to 255 with a greater
// probability assigned to the ranges 1 - 3 and 253 - 255 to exercise
// boundary conditions
//--------------------------------------------------------------------------- 
function [7:0] random_nfail_0_255;
  input       dummy;
  integer     rnd_1;
  integer     rnd_2;

  begin
    rnd_1 = {$random} % 356;
    if (rnd_1 > 255) begin
      rnd_2 = {$random} % 3;
      if (rnd_1 < 307) random_nfail_0_255 = rnd_2 + 1;
      else             random_nfail_0_255 = 255 - rnd_2;
    end
    else
      random_nfail_0_255 = rnd_1;
  end
endfunction 

//--------------------------------------------------------------------------- 
// generate a random number between MIN_WCNT and MAX_WCNT
//--------------------------------------------------------------------------- 
function integer rand_wcnt_btw_min_max;
  input       dummy;
  integer     tmp;
  begin
    tmp = MIN_WCNT + {$random} % (MAX_WCNT-MIN_WCNT+1);
    rand_wcnt_btw_min_max = tmp;
  end
endfunction

//--------------------------------------------------------------------------- 
// generate a random number between MIN_WCNT and MAX_WCNT and is a multiple of 4
//--------------------------------------------------------------------------- 
function integer rand_wcnt_btw_min_max_mult_4;
  input       dummy;
  integer     tmp;
  begin
    tmp = 1;
    while ((tmp%4 != 0) || tmp < 4)
      tmp = MIN_WCNT + {$random} % (MAX_WCNT-MIN_WCNT+1);
    
    rand_wcnt_btw_min_max_mult_4 = tmp;
  end
endfunction

                 
//--------------------------------------------------------------------------- 
// generate a random number between MIN_WCNT and MAX_WCNT and is a multiple of 8
//--------------------------------------------------------------------------- 
function integer rand_wcnt_btw_min_max_mult_8;
  input       dummy;
  integer     tmp;
  begin
    tmp = 1;
    while ((tmp%8 != 0) || tmp < 8)
      tmp = MIN_WCNT + {$random} % (MAX_WCNT-MIN_WCNT+1);
    
    rand_wcnt_btw_min_max_mult_8 = tmp;
  end
endfunction


//--------------------------------------------------------------------------- 
// generate random column address, lower three bits must always be "000"
//--------------------------------------------------------------------------- 
function [11:0] random_bcol;
  input       dummy;
  reg [11:0]  tmp;
  begin
    tmp = {$random};
    tmp[2:0] = 3'b000;
    random_bcol = tmp;
  end
endfunction

  
//--------------------------------------------------------------------------- 
// generate random row address
//--------------------------------------------------------------------------- 
function [15:0] random_brow;
  input       dummy;
  reg [15:0]  tmp;
  begin
    tmp = {$random};
    random_brow = tmp;
  end
endfunction // random_brow

//--------------------------------------------------------------------------- 
// generate random bank address
//--------------------------------------------------------------------------- 
function [2:0] random_bbank;
  input       dummy;
  reg [2:0]  tmp;
  begin
    tmp = {$random};
    random_bbank = tmp;
  end
endfunction


//--------------------------------------------------------------------------- 
// generate random rank
//--------------------------------------------------------------------------- 
function [1:0] random_brank;
  input       dummy;
  reg [1:0]  tmp;
  begin
    tmp = {$random};
    random_brank = tmp;
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
    tmp = min + {$random} % (max-min+1);
    
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
  end
endfunction

// generate random wait time within MIN_WAIT and MAX_WAIT before STOP
function integer random_short_wait_clk;
  input      dummy;
  integer    tmp;
  begin
    tmp = 10 + {$random} % (20-10+1);
    random_short_wait_clk = tmp;
  end
endfunction // random_short_wait_clk


//--------------------------------------------------------------------------- 
// 
//--------------------------------------------------------------------------- 
// generate  
function [15:0] random_16b;
  input       dummy;
  reg [15:0]  tmp;
  begin
    tmp = {$random};
    random_16b = tmp;
  end
endfunction

//--------------------------------------------------------------------------- 
// Mask undriven address bits in LPDDR2 mode as well as ras, cas & we (no 
// longer driven)
//--------------------------------------------------------------------------- 
task set_default_mask;
  reg [11:0] csmsk; 
  reg [7:0] odtmsk;
  reg [7:0] ckemsk;
  reg [2:0] cidmsk;
  reg [3:0] bamsk;
  reg       parmsk;
  begin

//Below "csmsk" will be used when the design is run with "-nocs" option

    `ifdef DWC_AC_CS_USE
       csmsk = 12'd0;
    `else
       csmsk = {12'b0 | {(`DWC_PHY_CS_N_WIDTH){1'b1}}};
/*       if(`DWC_NO_OF_RANKS==1) 
       begin
         csmsk = 4'b0001;
       end
       else if(`DWC_NO_OF_RANKS==2)
       begin
         csmsk = 4'b0011; 
       end
       else if(`DWC_NO_OF_RANKS==3)
       begin
         csmsk = 4'b0111; 
       end
       else
       begin
         csmsk = 4'b1111;
       end
*/
    `endif  

//Below "odtmsk" will be used when the design is run with "-noodt" option

    `ifdef DWC_AC_ODT_USE
       odtmsk = 8'd0;
    `else
       odtmsk = { 8'd0 | {(`DWC_PHY_ODT_WIDTH){1'b1}}};

/*       if(`DWC_NO_OF_RANKS==1) 
       begin
         odtmsk = 4'b0001;
       end
       else if(`DWC_NO_OF_RANKS==2)
       begin
         odtmsk = 4'b0011; 
       end
       else if(`DWC_NO_OF_RANKS==3)
       begin
         odtmsk = 4'b0111; 
       end
       else
       begin
         odtmsk = 4'b1111;
       end
*/
    `endif  
// CKE MASK
    ckemsk = { 8'hff & {(`DWC_PHY_CKE_WIDTH){1'b0}}};

// CID MASK
   if (`NUM_3DS_STACKS > 1) begin
     cidmsk = { 3'b111 & {(`DWC_CID_WIDTH){1'b0}}};
   end 
   else begin
     cidmsk = 3'b111;
   end


//Below used for Rdimm with -nopar option...

    `ifdef DWC_AC_PARITY_USE
       parmsk = 1'b0;
    `else
       if(`DWC_NO_OF_RANKS < 3)
         parmsk = 1'b1; 
       else
         parmsk = 1'b0;
    `endif 

  // GEN3
    bamsk    = 0;
    bamsk[3] = (`DWC_BANK_WIDTH <= 3) ? 1'b1 : 1'b0;   // BA[3] mask
    bamsk[2] = (`DWC_BANK_WIDTH <= 2) ? 1'b1 : 1'b0;   // BA[2] mask

    `SYS.set_bistmskr1(
      `ifdef DWC_DX_DM_USE
                       4'h0,                                     // X4_DMMSK
      `else
                       4'hF,                                     // X4_DMMSK
      `endif
                       bamsk,                                   // BAMSK
                       ckemsk,                                  // CKEMSK
                       odtmsk,                                  // ODTMSK
      
                       cidmsk,                                  // CIDMSK
                       parmsk,                                  // PARMSK
      `ifdef DWC_DX_DM_USE
                       4'h0                                    // DMMSK
      `else
                       4'hF                                    // DMMSK
      `endif
                      );
     `ifdef LPDDR2 
      `GRM.bistmskr0[17:10] = 8'b1111_1111;                     // AMSK
      `GRM.bistmskr0[ 9: 0] = 10'b11_1111_1111;                 // AMSK
    `else
      `ifdef LPDDR3 
        `GRM.bistmskr0[17:10] = 8'b1111_1111;                   // AMSK
        `GRM.bistmskr0[ 9: 0] = 10'b11_1111_1111;               // AMSK
      `else
        `GRM.bistmskr0[17] = (`DWC_ADDR_WIDTH <= 17) ? 1'b1 : 1'b0; // ADDR[17] mask
        `GRM.bistmskr0[16] = (`DWC_ADDR_WIDTH <= 16) ? 1'b1 : 1'b0; // ADDR[16] mask
        `GRM.bistmskr0[15] = (`DWC_ADDR_WIDTH <= 15) ? 1'b1 : 1'b0; // ADDR[15] mask
        `GRM.bistmskr0[14] = (`DWC_ADDR_WIDTH <= 14) ? 1'b1 : 1'b0; // ADDR[14] mask
        `GRM.bistmskr0[13] = (`DWC_ADDR_WIDTH <= 13) ? 1'b1 : 1'b0; // ADDR[13] mask
      `endif
    `endif
    `SYS.set_bistmskr0(
                       `GRM.bistmskr0[17:0],                     // AMSK
                       1'b0,                                    // RASMSK
                       csmsk                                   // CSMSK
                      );

    `SYS.set_bistmskr2(32'h0000_0000);                          // DQMSK
    `FCOV_REG.set_cov_registers_write(`BISTMSKR0,`GRM.bistmskr0,`VALUE_REGISTER_DATA);
    `FCOV_REG.set_cov_registers_write(`BISTMSKR1,`GRM.bistmskr1,`VALUE_REGISTER_DATA);
    `FCOV_REG.set_cov_registers_write(`BISTMSKR2,`GRM.bistmskr2,`VALUE_REGISTER_DATA);
  end
endtask

//--------------------------------------------------------------------------- 
// 
//--------------------------------------------------------------------------- 
task check_all_bist_status;
  reg [31:0] tmp;
  begin
      // For bist done statue on JTAG, it is hardly to predict
      // if bist fsm is already in done state by the time data is
      // read. Hence, only check for done status, when `GRM.bistgsr[0]
      // is set to 1.
`ifdef DWC_DDRPHY_JTAG
      if (`GRM.bistgsr[0] === 1'b0) begin
        `CFG.disable_read_compare;
        `CFG.read_register_data(`BISTGSR, tmp);
        if (tmp[31:1] != `GRM.bistgsr[31:1]) begin
          `SYS.error;
          $display("-> %0t: [BIST_COMMON] ERROR: BISTGSR VALUES mismatch!!!  Expected 0x%h but got 0x%h [Ignore bit 0]",$time, `GRM.bistgsr, tmp);
        end
        repeat (2) @(posedge `CFG.clk);      
        `CFG.disable_read_compare;
      end
      else begin
      `CFG.read_register(`BISTGSR);
      end        
`else
      `CFG.read_register(`BISTGSR);
`endif
    
`ifdef FUNCOV
      `CFG.disable_read_compare;
      // purpose is to sample the WCSR 
      `CFG.read_register(`BISTWCSR);
      repeat (2) @(posedge `CFG.clk);      
      `CFG.enable_read_compare;    
`else   
    if (!skip) `CFG.read_register(`BISTWCSR);
`endif
    `CFG.read_register(`BISTWER0);
    `CFG.read_register(`BISTWER1);
    `CFG.read_register(`BISTBER0);
    `CFG.read_register(`BISTBER1);
    `CFG.read_register(`BISTBER2);
    `CFG.read_register(`BISTBER3);
    `CFG.read_register(`BISTBER4);
    `CFG.read_register(`BISTBER5);
    `CFG.read_register(`BISTFWR0);
    `CFG.read_register(`BISTFWR1);
    `CFG.read_register(`BISTFWR2);
  end
endtask

task check_all_bist_status_with_wait_done;
  begin
    // wait for register status to be update after STOP
    wait ((`PUB.u_DWC_ddrphy_bist.o_dx_done == 1) || (`PUB.u_DWC_ddrphy_bist.o_ac_done == 1));
    repeat (10) @(posedge `SYS.clk);
    `CFG.read_register(`BISTGSR);
    `CFG.read_register(`BISTWCSR);
    `CFG.read_register(`BISTWER0);
    `CFG.read_register(`BISTWER1);
    `CFG.read_register(`BISTBER0);
    `CFG.read_register(`BISTBER1);
    `CFG.read_register(`BISTBER2);
    `CFG.read_register(`BISTBER3);
    `CFG.read_register(`BISTBER4);
    `CFG.read_register(`BISTBER5);
    `CFG.read_register(`BISTFWR0);
    `CFG.read_register(`BISTFWR1);
    `CFG.read_register(`BISTFWR2);
    repeat (10) @(posedge `SYS.clk);
  end
endtask // check_all_bist_status


task check_bist_stuck_status;
  begin
    `CFG.read_register(`BISTGSR);

    // purpose is to sample the BISTWCSR, BISTWER, BISTFWR0-2 as stuck at would keep counting
`ifdef FUNCOV
    `CFG.disable_read_compare;
    `CFG.read_register(`BISTWCSR);
    `CFG.read_register(`BISTWER0);
    `CFG.read_register(`BISTWER1);
    `CFG.read_register(`BISTFWR0);
    `CFG.read_register(`BISTFWR1);
    `CFG.read_register(`BISTFWR2);
    repeat (2) @(posedge `CFG.clk);      
    `CFG.enable_read_compare;    
`endif
    `CFG.read_register(`BISTBER0);
    `CFG.read_register(`BISTBER1);
    `CFG.read_register(`BISTBER2);
    `CFG.read_register(`BISTBER3);
    `CFG.read_register(`BISTBER5);
   end
endtask // check_bist_stuck_status


task check_dx_bist_stuck_status;
  begin
    `CFG.read_register(`BISTGSR);
    // purpose is to sample the BISTWCSR, BISTWER, BISTFWR0-1 as stuck at would keep counting
`ifdef FUNCOV
    `CFG.disable_read_compare;
    `CFG.read_register(`BISTWCSR);
    `CFG.read_register(`BISTWER0);
    `CFG.read_register(`BISTWER1);
      repeat (2) @(posedge `CFG.clk);      
    `CFG.enable_read_compare;    
`endif
    `CFG.read_register(`BISTBER0);
    `CFG.read_register(`BISTBER1);
    `CFG.read_register(`BISTBER2);
    `CFG.read_register(`BISTBER3);
    `CFG.read_register(`BISTBER5);
    `CFG.read_register(`BISTFWR0);
    `CFG.read_register(`BISTFWR1);
    `CFG.read_register(`BISTFWR2);
  end
endtask // check_bist_stuck_status


// ---------------------------------------------------------------------
// Task to randomly select lbdqss, lbgdqs and iolb
// ---------------------------------------------------------------------
task t_random_lbdqss_lbgdqs_iolb;
  reg       iolb;
  reg       lbdqss;
  reg [1:0] lbgdqs;
  begin
    // Check bist stuck error only once as it takes long to simulate
    // ***TBD: add random on LBDQSS and LBGDQS later
    `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, 1, iolb);
//    `SYS.RANDOM_RANGE(`SYS.seed, 0, 3, lbdqss);
//    `SYS.RANDOM_RANGE(`SYS.seed, 0, 2, lbgdqs);
    lbdqss = `LB_DQSS_AUTO;
    lbgdqs = `LB_GDQS_ON;

    $display ("\n");
    $display ("-> %0t: [BENCH] --------------------- LOOPBACK CONFIGURATION ------------------------", $time);
    $display ("-> %0t: [BENCH] IOLB = %0d   LBDQSS = %0d   LBGDQS = %0d", $time, iolb, lbdqss, lbgdqs);
    $display ("-> %0t: [BENCH] ---------------------------------------------------------------------", $time);
    `SYS.configure_loopback(iolb, lbdqss, lbgdqs);
    // Disable ODT monitor during BIST testing
    `SYS.disable_all_odt_monitors;

    `SYS.disable_undefined_warning;
  end
endtask // t_random_lbdqss_lbgdqs_iolb


//--------------------------------------------------------------------------- 
//--------------------------------------------------------------------------- 
always @(`PHY_TOP.ck or `PHY_TOP.ck_n)
  begin
    case (`GRM.bistrr[24:23])
      0: tst_ck = `PHY_TOP.ck[0];
`ifdef MSD_CK_1
      1: tst_ck = `PHY_TOP.ck[1];
`endif
`ifdef MSD_CK_2
      2: tst_ck = `PHY_TOP.ck[2];
`endif
      default: tst_ck = `PHY_TOP.ck[0];
    endcase // case(tmp_bcksel)
  end
  

//--------------------------------------------------------------------------- 
// predict expect AC BIST pattern from input position
//--------------------------------------------------------------------------- 
task exp_ac_pattern;
  input integer                         curr_exp_pos;
  input  reg                            odd_last_pos;
  output reg [TOTAL_AC_PATTERN_WIDTH-1:0]  cal_pattern;
  
  reg [`PUB_ADDR_WIDTH-1:0]             exp_a;
  reg [`DWC_BANK_WIDTH-1:0]             exp_ba;
  reg                                   exp_we_b;
  reg                                   exp_cas_b;
  reg                                   exp_ras_b;
  reg [`DWC_NO_OF_RANKS-1:0]            exp_cs_b;
  reg [`DWC_NO_OF_RANKS-1:0]            exp_odt;
  reg [`DWC_NO_OF_RANKS-1:0]            exp_cke;
  reg                                   exp_parity;
  
  begin

    if (pattern == `PUB_DATA_WALKING_0) begin
      if (`GRM.lpddr2_mode == 1) begin
        {            exp_cke,          exp_cs_b,                                         exp_a[9:0]} = {pLPDDR2_PATTERN_WIDTH{1'b1}};
        {exp_parity,          exp_odt,           exp_ras_b, exp_cas_b, exp_we_b, exp_ba            } = 0;
      end
      else if (`GRM.lpddr3_mode == 1) begin
        {            exp_cke, exp_odt, exp_cs_b,                                         exp_a[9:0]} = {pLPDDR3_PATTERN_WIDTH{1'b1}};
        {exp_parity,                             exp_ras_b, exp_cas_b, exp_we_b, exp_ba            } = 0;
      end
      else
        {exp_parity, exp_cke, exp_odt, exp_cs_b, exp_ras_b,                      exp_ba, exp_a     } = {TOTAL_AC_PATTERN_WIDTH{1'b1}};
    end
    else if (pattern == `PUB_DATA_WALKING_1) begin
      if (`GRM.lpddr2_mode == 1) begin
        {            exp_cke,          exp_cs_b,                                         exp_a[9:0]} = {pLPDDR2_PATTERN_WIDTH{1'b0}};
        {exp_parity,          exp_odt,           exp_ras_b, exp_cas_b, exp_we_b, exp_ba            } = 0;
      end
      else if (`GRM.lpddr3_mode == 1) begin
        {            exp_cke, exp_odt, exp_cs_b,                                         exp_a[9:0]} = {pLPDDR3_PATTERN_WIDTH{1'b0}};
        {exp_parity,                             exp_ras_b, exp_cas_b, exp_we_b, exp_ba            } = 0;
      end
      else
        {exp_parity, exp_cke, exp_odt, exp_cs_b, exp_ras_b,                      exp_ba, exp_a     } = {TOTAL_AC_PATTERN_WIDTH{1'b0}};
    end
    else begin
      // lfsr or user program
      $display ("-> %0t: [BENCH] pattern check not supported yet on AC", $time);
    end

    `ifdef DWC_DDR_RDIMM
      if (`DWC_NO_OF_RANKS > 2) exp_parity = 1'b0;
    `else
      `ifndef DWC_AC_PARITY_USE 
        exp_parity = 1'b0;
      `endif
    `endif

    // Check which signal has the last walking pattern...
    // Sequence goes like:  a[MSB]     ->    a[0]
    //                      cs_n[MSB]  -> cs_n[0]
    //                      cke[MSB]   ->  cke[0]
    //                      ba[MSB]    ->   ba[0]
    // `ifndef DWC_DDRPHY_GEN3
    //                      we_n
    //                      cas_n
    // `endif
    //                      ras_n/act_n
    //                      odt[MSB]   ->  odt[0]
    //                      par

    // DDRn modes
    if (`GRM.lpddrx_mode == 0) begin
      exp_a      = build_ac_sig_pattern(pAC_POS_FIELD_A_LO,     pAC_POS_FIELD_A_HI,     curr_exp_pos, exp_a,      "a");
      exp_cs_b   = build_ac_sig_pattern(pAC_POS_FIELD_CSN_LO,   pAC_POS_FIELD_CSN_HI,   curr_exp_pos, exp_cs_b,   "cs_n");
      exp_cke    = build_ac_sig_pattern(pAC_POS_FIELD_CKE_LO,   pAC_POS_FIELD_CKE_HI,   curr_exp_pos, exp_cke,    "cke");
      exp_odt    = build_ac_sig_pattern(pAC_POS_FIELD_ODT_LO,   pAC_POS_FIELD_ODT_HI,   curr_exp_pos, exp_odt,    "odt");
`ifndef LPDDRX
      exp_ba     = build_ac_sig_pattern(pAC_POS_FIELD_BA_LO,    pAC_POS_FIELD_BA_HI,    curr_exp_pos, exp_ba,     "ba");
      exp_ras_b  = build_ac_sig_pattern(pAC_POS_FIELD_RASN_LO,  pAC_POS_FIELD_RASN_HI,  curr_exp_pos, exp_ras_b,  "ras_n");
      exp_parity = build_ac_sig_pattern(pAC_POS_FIELD_PARITY_LO, pAC_POS_FIELD_PARITY_HI, curr_exp_pos, exp_parity, "par");
`endif
    end
    else begin
      exp_a      = build_ac_sig_pattern(pAC_POS_FIELD_A_LO,     pAC_POS_FIELD_A_HI,     curr_exp_pos, exp_a,      "a");
      exp_cs_b   = build_ac_sig_pattern(pAC_POS_FIELD_CSN_LO,   pAC_POS_FIELD_CSN_HI,   curr_exp_pos, exp_cs_b,   "cs_n");
      exp_cke    = build_ac_sig_pattern(pAC_POS_FIELD_CKE_LO,   pAC_POS_FIELD_CKE_HI,   curr_exp_pos, exp_cke,    "cke");
`ifdef LPDDR3
      exp_odt    = build_ac_sig_pattern(pAC_POS_FIELD_ODT_LO,   pAC_POS_FIELD_ODT_HI,   curr_exp_pos, exp_odt,    "odt");
`endif
    end

    if (`GRM.lpddr2_mode == 1) begin
      cal_pattern = {TOTAL_AC_PATTERN_WIDTH{1'b0}};
      cal_pattern = {                                                              exp_cke, exp_cs_b, exp_a[9:0]};
    end
    else if (`GRM.lpddr3_mode == 1) begin
      cal_pattern = {TOTAL_AC_PATTERN_WIDTH{1'b0}};
      cal_pattern = {            exp_odt,                                          exp_cke, exp_cs_b, exp_a[9:0]};
    end
    else
      cal_pattern = {exp_parity, exp_odt, exp_ras_b,                       exp_ba, exp_cke, exp_cs_b, exp_a};

  end
endtask // exp_ac_pattern

// -----------------------------------------------------------------------------
// Generically builds pattern for each signal; uses a default maximum
// signal width of 32-bits for any one signal
// -----------------------------------------------------------------------------
function [32 -1:0] build_ac_sig_pattern;
  input integer              idx_low;
  input integer              idx_high;
  input integer              curr_exp_idx;
  input reg [32        -1:0] exp_init_sig;
  input reg [(8 * 100)  : 0] str_sig_name;

        integer              curr_sig_idx;
        reg [32        -1:0] exp_sig;

  begin
    exp_sig = exp_init_sig;
    if ((curr_exp_idx >= idx_low) && (curr_exp_idx <= idx_high)) begin
      curr_sig_idx = curr_exp_idx - idx_low;
      exp_sig[curr_sig_idx] = (pattern == `PUB_DATA_WALKING_0) ? 1'b0 : 
                              (pattern == `PUB_DATA_WALKING_1) ? 1'b1 : 1'bx;
      if (pattern == `PUB_DATA_WALKING_0 || pattern == `PUB_DATA_WALKING_1)
        $display ("-> %0t: [BENCH] At the end of BIST, pattern (walking 1 or 0) should be located at `TB.%0s[%0d]", $time, str_sig_name, curr_sig_idx);
    end
    build_ac_sig_pattern = exp_sig;
  end
endfunction

// -------------------------------------------------------------------------------------------------------------------
// Check lp pattern when ac_lp is coming out of state of wait, compare the bist pattern observed from the outputs with the expected
// NB: probing into RTL code is done.
// -------------------------------------------------------------------------------------------------------------------
always @(negedge `PUB.bist_raw_cmd_mode) begin: check_ac_lp_pattern
  reg            tmp_a;
  reg            tmp_ba;
  reg            tmp_cs_n;
  reg            tmp_cke;
  reg            tmp_we_n;
  reg            tmp_cas_n;
  reg            tmp_ras_n;
  reg            tmp_odt;
  reg [2   -1:0] tmp_parity;

  reg [`PUB_ADDR_WIDTH-1:0]             exp_a;
  reg [`DWC_BANK_WIDTH-1:0]             exp_ba;
  reg                                   exp_we_b;
  reg                                   exp_cas_b;
  reg                                   exp_ras_b;
  reg [`DWC_NO_OF_RANKS-1:0]            exp_cs_b;
  reg [`DWC_NO_OF_RANKS-1:0]            exp_odt;
  reg [`DWC_NO_OF_RANKS-1:0]            exp_cke;
  reg                                   exp_parity;
  
  if (check_ac_lp === 1'b1) begin
    $display("%0t DEBUG - check_ac_lp_pattern ", $time);

    // call task exp_ac_pattern to find out the pattern
    $display ("-> %0t: [BENCH] pattern = %0d  position = %0d on AC loopback mode", $time, pattern, position);
    exp_ac_pattern (position, odd_last_pos, exp_ac_bist);

    if (`GRM.lpddr2_mode == 1)
      {exp_cke,          exp_cs_b, exp_a[9:0]} = exp_ac_bist[pLPDDR2_PATTERN_WIDTH - 1 : 0];
    else if (`GRM.lpddr3_mode == 1)
      {exp_cke, exp_odt, exp_cs_b, exp_a[9:0]} = exp_ac_bist[pLPDDR3_PATTERN_WIDTH - 1 : 0];
    else
      {exp_parity, exp_odt, exp_ras_b,                      exp_ba, exp_cke, exp_cs_b, exp_a} = exp_ac_bist;

    // Main block to check all signals simultaneously....instead of sequentially
    fork

      begin: CHECK_A
        integer chk_idx_a;
        integer tb_idx_a;
        // LPDDRX Mode
        if (`GRM.lpddrx_mode == 1) begin
          if (`TB.a[9:0] != exp_a[9:0]) begin
            for (chk_idx_a = pAC_POS_FIELD_A_LO; chk_idx_a <= pAC_POS_FIELD_A_HI; chk_idx_a = chk_idx_a + 1) begin
              tb_idx_a = chk_idx_a - pAC_POS_FIELD_A_LO;
              if (chk_idx_a == position || chk_idx_a == position + 1) begin
                @(posedge tst_ck);
                tmp_a = `TB.a[tb_idx_a];
                @(posedge tst_ck);
                if (`TB.a[tb_idx_a] == tmp_a) begin
                  `SYS.error;
                  $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern; expected `TB.a[%0d] should be toggling", $time, tb_idx_a);
                end
              end
              else begin
                if (`TB.a[tb_idx_a] != exp_a[tb_idx_a]) begin
                  `SYS.error;
                  $display ("-> %0t: [BENCH] ERROR: mismatch AC pattern - got `TB.a[%0d] = %0h  expected %0h", $time, tb_idx_a, `TB.a[tb_idx_a], exp_a[tb_idx_a]);
                end
              end
            end
          end
        end
        // DDRn Modes
        else begin
          $display("%0t DEBUG - CHECK_A position = %0d  pAC_POS_FIELD_A_LO=%0d pAC_POS_FIELD_A_HI=%0d", $time, position, pAC_POS_FIELD_A_LO, pAC_POS_FIELD_A_HI);
          if (`TB.a != exp_a) begin
            for (chk_idx_a = pAC_POS_FIELD_A_LO; chk_idx_a <= pAC_POS_FIELD_A_HI; chk_idx_a = chk_idx_a + 1) begin
              tb_idx_a = chk_idx_a - pAC_POS_FIELD_A_LO;
              $display("%0t DEBUG - CHECK_A chk_idx_a = %0d  tb_idx_a=%0d", $time, chk_idx_a, tb_idx_a);
              if (chk_idx_a == position || chk_idx_a == position - 1) begin
                $display("%0t DEBUG - CHECK_A chk_idx_a = %0d   position = %0d", $time, chk_idx_a, position);
                @(posedge tst_ck);
                tmp_a = `TB.a[tb_idx_a];
                $display("%0t DEBUG - CHECK_A tmp_a = %b  `TB.a[%0d] = %b", $time, tmp_a, tb_idx_a, `TB.a[tb_idx_a]);
                @(posedge tst_ck);
                $display("%0t DEBUG - CHECK_A tmp_a = %b  `TB.a[%0d] = %b", $time, tmp_a, tb_idx_a, `TB.a[tb_idx_a]);
                if (`TB.a[tb_idx_a] == tmp_a) begin
                  `SYS.error;
                  $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern; expected `TB.a[%0d] should be toggling", $time, tb_idx_a);
                end
              end
              else begin
                if (`TB.a[tb_idx_a] != exp_a[tb_idx_a]) begin
                  `SYS.error;
                  $display ("-> %0t: [BENCH] ERROR: mismatch AC pattern - got `TB.a[%0d] = %0h  expected  %0h", $time, tb_idx_a,`TB.a[tb_idx_a], exp_a[tb_idx_a]);
                end
              end
            end 
          end
        end // else: !if(`GRM.lpddrx_mode == 1)
      end // block: CHECK_A
      
`ifndef LPDDRX
      begin: CHECK_BA
        integer chk_idx_ba;
        integer tb_idx_ba;
        if (`TB.ba != exp_ba) begin
          for (chk_idx_ba = pAC_POS_FIELD_BA_LO; chk_idx_ba <= pAC_POS_FIELD_BA_HI; chk_idx_ba = chk_idx_ba + 1) begin
            tb_idx_ba = chk_idx_ba - pAC_POS_FIELD_BA_LO;
$display("%0t DEBUG - CHECK_BA - chk_idx_ba=%0d tb_idx_ba=%0d   `TB.ba (%b) != exp_ba (%b)   [pAC_POS_FIELD_BA_LO=%0d pAC_POS_FIELD_BA_HI=%0d]", $time, chk_idx_ba, tb_idx_ba, `TB.ba, exp_ba, pAC_POS_FIELD_BA_LO, pAC_POS_FIELD_BA_HI);
            if (chk_idx_ba == position || chk_idx_ba == position - 1) begin
$display("%0t DEBUG - CHECK_BA - position=%0d ", $time, position);
              @(posedge tst_ck);
              tmp_ba = `TB.ba[tb_idx_ba];
$display("%0t DEBUG - CHECK_BA - tmp_ba=%b <- `TB.ba[%0d]=%b", $time, tmp_ba, tb_idx_ba, `TB.ba[tb_idx_ba]);
              @(posedge tst_ck);
              if (`TB.ba[tb_idx_ba] == tmp_ba) begin
                `SYS.error;
                $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern; expected `TB.ba[%0d] should be toggling", $time, tb_idx_ba);
              end
            end
            else begin
              if (`TB.ba[tb_idx_ba] != exp_ba[tb_idx_ba]) begin
                `SYS.error;
                $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern - got `TB.ba[%0d] = %0h  expected  %0h", $time, tb_idx_ba,`TB.ba[tb_idx_ba], exp_ba[tb_idx_ba]);
              end
            end
          end
        end
      end
`endif
      
      begin: CHECK_CS_N
        integer chk_idx_cs;
        integer tb_idx_cs;
        $display("%0t DEBUG - CHECK_CS position = %0d  pAC_POS_FIELD_CSN_LO=%0d pAC_POS_FIELD_CSN_HI=%0d", $time, position, pAC_POS_FIELD_CSN_LO, pAC_POS_FIELD_CSN_HI);
        if (`TB.cs_n != exp_cs_b) begin
          for (chk_idx_cs = pAC_POS_FIELD_CSN_LO; chk_idx_cs <= pAC_POS_FIELD_CSN_HI; chk_idx_cs = chk_idx_cs + 1) begin
            tb_idx_cs = chk_idx_cs - pAC_POS_FIELD_CSN_LO;
            $display("%0t DEBUG - CHECK_CS chk_idx_cs = %0d  tb_idx_cs=%0d", $time, chk_idx_cs, tb_idx_cs);
            if (chk_idx_cs == position || chk_idx_cs == position - 1) begin
              @(posedge tst_ck);
              tmp_cs_n = `TB.cs_n[tb_idx_cs];
              @(posedge tst_ck);
              if (`TB.cs_n[tb_idx_cs] == tmp_cs_n) begin
                `SYS.error;
                $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern; expected `TB.cs_n[%0d] should be toggling", $time, tb_idx_cs);
              end
            end
            else begin
              if (`TB.cs_n[tb_idx_cs] != exp_cs_b[tb_idx_cs]) begin
                `SYS.error;
                $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern - got `TB.cs_n[%0d] = %0h  expected  %0h", $time, tb_idx_cs, `TB.cs_n[tb_idx_cs], exp_cs_b[tb_idx_cs]);
              end
            end
          end
        end
      end
      
      begin: CHECK_CKE
        integer chk_idx_cke;
        integer tb_idx_cke;
        if (`TB.cke != exp_cke) begin
          for (chk_idx_cke = pAC_POS_FIELD_CKE_LO; chk_idx_cke <= pAC_POS_FIELD_CKE_HI; chk_idx_cke = chk_idx_cke + 1) begin
            tb_idx_cke = chk_idx_cke - pAC_POS_FIELD_CKE_LO;
            if (chk_idx_cke == position || chk_idx_cke == position - 1) begin
              @(posedge tst_ck);
              tmp_cke = `TB.cke[tb_idx_cke];
              @(posedge tst_ck);
              if (`TB.cke[tb_idx_cke] == tmp_cke) begin
                `SYS.error;
                $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern; expected `TB.cke[%0d] should be toggling", $time, tb_idx_cke);
              end
            end
            else begin
              if (`TB.cke[tb_idx_cke] != exp_cke[tb_idx_cke]) begin
                `SYS.error;
                $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern - got `TB.cke[%0d] = %0h  expected  %0h", $time, tb_idx_cke, `TB.cke[tb_idx_cke], exp_cke[tb_idx_cke]);
              end
            end
          end
        end
      end


  `ifndef LPDDRX
      // There is no ras_n pin on the GEN3 PHY - only the act_n pin.  It occupies the same place in the pattern as did the ras_n
      begin: CHECK_ACT_N
        if (`TB.act_n != exp_ras_b) begin
          if (position==pAC_POS_FIELD_RASN_LO || position-1==pAC_POS_FIELD_RASN_LO) begin
            @(posedge tst_ck);
            tmp_ras_n = `TB.act_n;
            @(posedge tst_ck);
            if (`TB.act_n == tmp_ras_n) begin
              `SYS.error;
              $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern; expected `TB.act_n should be toggling", $time);
            end
          end
          else begin          
            `SYS.error;
            $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern - got `TB.act_n = %0h  expected  %0h", $time, `TB.act_n, exp_ras_b);
          end
        end
      end
  `endif

      begin: CHECK_ODT
        integer chk_idx_odt;
        integer tb_idx_odt;
        $display("%0t DEBUG - CHECK_ODT position = %0d  pAC_POS_FIELD_ODT_LO=%0d pAC_POS_FIELD_ODT_HI=%0d", $time, position, pAC_POS_FIELD_ODT_LO, pAC_POS_FIELD_ODT_HI);
        if (`TB.odt != exp_odt) begin
          for (chk_idx_odt = pAC_POS_FIELD_ODT_LO; chk_idx_odt <= pAC_POS_FIELD_ODT_HI; chk_idx_odt = chk_idx_odt + 1) begin
            tb_idx_odt = chk_idx_odt - pAC_POS_FIELD_ODT_LO;
            $display("%0t DEBUG - CHECK_ODT chk_idx_odt = %0d  tb_idx_odt=%0d", $time, chk_idx_odt, tb_idx_odt);
            if (chk_idx_odt == position || chk_idx_odt == position - 1) begin
              @(posedge tst_ck);
              tmp_odt = `TB.odt[tb_idx_odt];
              @(posedge tst_ck);
              if (`TB.odt[tb_idx_odt] == tmp_odt) begin
                `SYS.error;
                $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern; expected `TB.odt[%0d] should be toggling", $time, tb_idx_odt);
              end
            end
            else begin
              if (`TB.odt[tb_idx_odt] != exp_odt[tb_idx_odt]) begin
                `SYS.error;
                $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern - got `TB.odt[%0d] = %0h  expected  %0h", $time, tb_idx_odt,`TB.odt[tb_idx_odt], exp_odt[tb_idx_odt]);
              end
            end
          end
        end
      end

`ifndef LPDDRX
      // Sample the value BIST is driving rather than the CHIP.par 
      // output since this will change once loopback is deasserted 
      // (par is calculated by PUB under PUB non-loopback mode)
      begin: CHECK_PARITY
        integer last_cmd_slot_odd;
        $display("%0t DEBUG - CHECK_PARITY", $time);
        // This signal toggles when the pattern is on the even or odd cmd
        // slots so we need to check against two index values (based on the
        // sample patterns below)
        if ((position == pAC_POS_FIELD_PARITY_LO) || (position == 0)) begin
          $display("%0t DEBUG - CHECK_PARITY position = %0d  pAC_POS_FIELD_PARITY_LO=%0d pAC_POS_FIELD_PARITY_LO=%0d", $time, position, pAC_POS_FIELD_PARITY_LO, pAC_POS_FIELD_PARITY_LO);
          // If the position/index where the pattern is expected to end up is odd (i.e. pattern width is even since par is the MSB
          // bit), then the pattern will be on the odd cmd slot (never on the even slot since the pattern starts on bit 0 and jumps by
          // 2 bits every time).  Example of a walking 0 pattern for an odd AC pattern/signal width:
          //
          //  Cmd slot     Odd      Even
          //             1111 1101   1111 1110  Pattern on even bits is on even cmd slot only
          //             1111 0111   1111 1011   "  & pattern on odd bits is on odd cmd slot only
          //             1101 1111   1110 1111   "     "
          //             0111 1110   1011 1111   "     "  par toggles on MSB (odd slot only)
          // Bit       MSB                 LSB
          if (total_bist_pattern_width[0] == 1'b0) begin
            // With an even pattern width, the MSB bit sees the pattern only on the odd cmd slot (see sample pattern above)
            if (   ((pattern == `PUB_DATA_WALKING_0) && (`PUB.bist_dfi_parity != 2'b01))
                || ((pattern == `PUB_DATA_WALKING_1) && (`PUB.bist_dfi_parity != 2'b10))
               ) begin
              `SYS.error;
              $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern; expected `PUB.bist_dfi_parity should be toggling (pattern is on odd cmd slot)", $time);
            end
          end
          // If the pattern width is odd, the pattern can end up on either the even or odd cmd slots for any bit.
          // It starts off on the even bits even cmd slot and odd bits on th eodd cmd slot but then crosses over
          // to even bits on the odd cmd slot and odd bits on the even cmd slot when the pattern rolls over, 
          // alternating thereafter.  Example of a walking 0 pattern for an odd AC pattern/signal width:
          //
          // Cmd slot      Odd        Even
          //             111 1101   111 1110  Pattern on even bits in even cmd slot and odd bits in odd cmd slot
          //             111 0111   111 1011   "
          //             101 1111   110 1111   "
          //             111 1110   011 1111   " par toggles on MSB (even slot)
          //             111 1011   111 1101  Pattern on odd bits in even cmd slot and even bits on odd cmd slot
          //             110 1111   111 0111   "
          //             011 1111   101 1111   " par toggles on MSB (odd slot)
          // Bit       MSB                 LSB
          else begin
            // Determine where is in terms of whether it is stepping along the even signal bits or odd signal bits.
            last_cmd_slot_odd = (`GRM.bistwcr[15:0] * 2) / total_bist_pattern_width; 
            // On an even command slot, pattern is stepping along the even bits
            if (last_cmd_slot_odd[0] == 1'b0) begin
              // With an odd pattern width & pattern on even bits, the MSB bit sees the pattern only on the odd cmd slot (see sample pattern above)
              if (   ((pattern == `PUB_DATA_WALKING_0) && (`PUB.bist_dfi_parity != 2'b01))
                  || ((pattern == `PUB_DATA_WALKING_1) && (`PUB.bist_dfi_parity != 2'b10))
                 ) begin
                `SYS.error;
                $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern; expected `PUB.bist_dfi_parity should be toggling (pattern is on odd cmd slot)", $time);
              end
            end
            // On an odd command slot, pattern is stepping along the odd bits
            else begin
              // With an odd pattern width & pattern on odd bits, the MSB bit sees the pattern only on the even cmd slot (see sample pattern above)
              if (   ((pattern == `PUB_DATA_WALKING_0) && (`PUB.bist_dfi_parity != 2'b10))
                  || ((pattern == `PUB_DATA_WALKING_1) && (`PUB.bist_dfi_parity != 2'b01))
                 ) begin
                `SYS.error;
                $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern; expected `PUB.bist_dfi_parity should be toggling (pattern is on even cmd slot)", $time);
              end
            end
          end
        end
        // If the pattern is not on the par signal, we don't expect it to toggle
        else begin
          if (`PUB.bist_dfi_parity != {2{exp_parity}}) begin
            `SYS.error;
            $display ("-> %0t: [BENCH]  ERROR: mismatch AC pattern - got `PUB.bist_dfi_parity = 'b%b  expected  'b%b", $time, `PUB.bist_dfi_parity, {2{exp_parity}});
          end
        end

      end
`endif  // LPDDRX

    join

  end // if (check_ac_lp === 1'b1)
  
end // block: check_ac_lp_pattern;


//---------------------------------------------------------------------------
// make sure when ac lb generation is on, the pattern keeps on shifting
//---------------------------------------------------------------------------
always @(posedge `PHY_TOP.pub_ctl_clk)
  begin: check_ac_bist_pattern
    
    if ((`PUB.u_DWC_ddrphy_bist.u_bist_ac_lb.ac_gen_run == 1'b1) && (force_err_pattern_on == 0)) begin
      if(pattern ==  `PUB_DATA_WALKING_1 || pattern ==  `PUB_DATA_WALKING_0 || pattern == `PUB_DATA_LFSR || pattern ==  `PUB_DATA_USER_PATTERN)  begin   
        if (prev_raw_ac == `PUB.u_DWC_ddrphy_bist.u_bist_ac_lb.raw_ac) begin
          `SYS.error;
          $display ("-> %0t: [BENCH]  ERROR: AC LB raw_ac pattern remains stationary", $time);
        end
      end
      else if(pattern ==  `PUB_DATA_0000_0000 || pattern ==  `PUB_DATA_FFFF_FFFF || pattern == `PUB_DATA_5555_5555 || pattern ==  `PUB_DATA_AAAA_AAAA  
              || pattern ==  `PUB_DATA_00FF_00FF  || pattern ==  `PUB_DATA_FF00_FF00 )  begin 
        if (prev_raw_ac != `PUB.u_DWC_ddrphy_bist.u_bist_ac_lb.raw_ac) begin
          `SYS.error;
          $display ("-> %0t: [BENCH]  ERROR: AC LB raw_ac pattern does not remain stationary", $time);
        end
      end 
      
      prev_raw_ac = `PUB.u_DWC_ddrphy_bist.u_bist_ac_lb.raw_ac;
    end
    else
      prev_raw_ac = {TOTAL_AC_PATTERN_WIDTH{1'bx}};
      
  end

//--------------------------------------------------------------------------- 
// predict expect DX BIST pattern for error insertion
//--------------------------------------------------------------------------- 
task exp_dx_pattern;
  input integer                       pos;
  input integer                       pattern;
  output reg [`DWC_NO_OF_BYTES*8*4-1:0]   cal_dq_pattern;
  output reg [`DWC_NO_OF_BYTES*4-1:0]     cal_dm_pattern;
  reg [7:0]                           tmp_dq_beat3, tmp_dq_beat2, tmp_dq_beat1, tmp_dq_beat0;
  reg                                 tmp_dm_beat3, tmp_dm_beat2, tmp_dm_beat1, tmp_dm_beat0;
  //reg [15:0]                          tmp_udp_dq_f, tmp_udp_dq_r;  //for USER Data Pattern only
  integer                             i;
  
  begin

    // basic pattern 
    if (pattern == `PUB_DATA_WALKING_0) begin
      tmp_dq_beat0 = 8'b1111_1110;
      tmp_dq_beat1 = 8'b1110_1111;
      tmp_dq_beat2 = {tmp_dq_beat0[6:0], tmp_dq_beat0[7]};
      tmp_dq_beat3 = {tmp_dq_beat1[6:0], tmp_dq_beat1[7]};
    end
    else if (pattern == `PUB_DATA_WALKING_1) begin
      tmp_dq_beat0 = 8'b0000_0001;
      tmp_dq_beat1 = 8'b0001_0000;
      tmp_dq_beat2 = {tmp_dq_beat0[6:0], tmp_dq_beat0[7]};
      tmp_dq_beat3 = {tmp_dq_beat1[6:0], tmp_dq_beat1[7]};
    end
    else if (pattern == `PUB_DATA_USER_PATTERN) begin
      // Check user data pattern with the pos information
      tmp_dq_beat0 = { 4{udp_dq_odd[(2*pos+0)%16], udp_dq_even[(2*pos+0)%16]} };
      tmp_dq_beat1 = { 4{udp_dq_odd[(2*pos+1)%16], udp_dq_even[(2*pos+1)%16]} };
      tmp_dq_beat2 = { 4{udp_dq_odd[(2*pos+2)%16], udp_dq_even[(2*pos+2)%16]} };
      tmp_dq_beat3 = { 4{udp_dq_odd[(2*pos+3)%16], udp_dq_even[(2*pos+3)%16]} };
    end
    else begin
      // lfsr or user program
      $display ("-> %0t: [BENCH] pattern check not supported yet on DX yet", $time);
    end

    if (gen_mask === 1'b1) begin
      tmp_dm_beat0 = 1'b0;
      tmp_dm_beat1 = ~tmp_dm_beat0;
    end
    else begin
      tmp_dm_beat0 = 1'b0;
      tmp_dm_beat1 = 1'b0;
    end
      
    // Check which signal has the last walking pattern...
    // ex: if lane_0 is used
    // Sequence goes like:  dq[7:0]    ->   dq[5:0], dq[7:6]     (for dq_r byte)
    //                      dq[15:8]   ->   dq[12:8], dq[15:13]  (for dq_f byte)
    //
    //                      dm[0]      ->   ~dm[0]               (for dm_r byte)
    //                      dm[1]      ->   ~dm[1]               (for dm_f byte)

    // no need to shift when in pos = 0, pattern shift depending on position
    if ((pattern == `PUB_DATA_WALKING_0) || (pattern == `PUB_DATA_WALKING_1)) begin
      for (i=1; i<=pos; i=i+1) begin
        tmp_dq_beat0[7:0] = {tmp_dq_beat0[5:0], tmp_dq_beat0[7:6]};
        tmp_dq_beat1[7:0] = {tmp_dq_beat1[5:0], tmp_dq_beat1[7:6]};
        tmp_dq_beat2[7:0] = {tmp_dq_beat2[5:0], tmp_dq_beat2[7:6]};
        tmp_dq_beat3[7:0] = {tmp_dq_beat3[5:0], tmp_dq_beat3[7:6]};
        if (gen_mask === 1'b1) begin
          tmp_dm_beat0 = ~tmp_dm_beat0;
          tmp_dm_beat1 = ~tmp_dm_beat1;
        end
        else begin
          tmp_dm_beat0 = 1'b0;
          tmp_dm_beat1 = 1'b0;
        end
      end
    end

    if (pattern == `PUB_DATA_USER_PATTERN) begin 
      for (i=1; i<=pos; i=i+1) begin
        if (gen_mask === 1'b1) begin
          tmp_dm_beat0 = ~tmp_dm_beat0;
          tmp_dm_beat1 = ~tmp_dm_beat1;
        end
        else begin
          tmp_dm_beat0 = 1'b0;
          tmp_dm_beat1 = 1'b0;
        end
      end
    end
      
    cal_dq_pattern = { {`DWC_NO_OF_BYTES{tmp_dq_beat3 & msbyte_udq_bytemask}}, {`DWC_NO_OF_BYTES{tmp_dq_beat2 & msbyte_udq_bytemask}}, 
                       {`DWC_NO_OF_BYTES{tmp_dq_beat1 & msbyte_udq_bytemask}}, {`DWC_NO_OF_BYTES{tmp_dq_beat0 & msbyte_udq_bytemask}} };
    
    `ifdef DWC_DX_DM_USE
    cal_dm_pattern = { {`DWC_NO_OF_BYTES{tmp_dm_beat0}}, {`DWC_NO_OF_BYTES{tmp_dm_beat1}}, 
                       {`DWC_NO_OF_BYTES{tmp_dm_beat1}}, {`DWC_NO_OF_BYTES{tmp_dm_beat0}} };
    `else
    cal_dm_pattern = { {`DWC_NO_OF_BYTES{1'b0}}, {`DWC_NO_OF_BYTES{1'b0}}, 
                       {`DWC_NO_OF_BYTES{1'b0}}, {`DWC_NO_OF_BYTES{1'b0}} };
    `endif
  end
endtask

  
//--------------------------------------------------------------------------- 
// predict expect DX BIST pattern from input position
//--------------------------------------------------------------------------- 
task exp_dx_pattern_for_dqs;
  input integer                       pos;
  input integer                       pattern;
  output reg [`DWC_NO_OF_BYTES*8*4-1:0]   cal_dq_pattern;
  output reg [`DWC_NO_OF_BYTES*4-1:0]     cal_dm_pattern;
  reg [7:0]                           tmp_dq_beat3, tmp_dq_beat2, tmp_dq_beat1, tmp_dq_beat0;
  reg [7:0]                           tmp_dq_beat1_wdbi, tmp_dq_beat0_wdbi;
  reg                                 tmp_dm_beat3, tmp_dm_beat2, tmp_dm_beat1, tmp_dm_beat0;
  reg                                 tmp_dm_beat1_wdbi, tmp_dm_beat0_wdbi;
  //reg [15:0]                          tmp_udp_dq_f, tmp_udp_dq_r;  //for USER Data Pattern only
  integer                             i;
  
  begin

    // basic pattern 
    if (pattern == `PUB_DATA_WALKING_0) begin
      tmp_dq_beat0 = 8'b1111_1110;
      tmp_dq_beat1 = 8'b1110_1111;
      tmp_dq_beat2 = {tmp_dq_beat0[6:0], tmp_dq_beat0[7]};
      tmp_dq_beat3 = {tmp_dq_beat1[6:0], tmp_dq_beat1[7]};
    end
    else if (pattern == `PUB_DATA_WALKING_1) begin
      tmp_dq_beat0 = 8'b0000_0001;
      tmp_dq_beat1 = 8'b0001_0000;
      tmp_dq_beat2 = {tmp_dq_beat0[6:0], tmp_dq_beat0[7]};
      tmp_dq_beat3 = {tmp_dq_beat1[6:0], tmp_dq_beat1[7]};
    end
    else if (pattern == `PUB_DATA_USER_PATTERN) begin
      // Check user data pattern with the pos information
      tmp_dq_beat0 = { 4{udp_dq_odd[(2*pos+0)%16], udp_dq_even[(2*pos+0)%16]} };
      tmp_dq_beat1 = { 4{udp_dq_odd[(2*pos+1)%16], udp_dq_even[(2*pos+1)%16]} };
      tmp_dq_beat2 = { 4{udp_dq_odd[(2*pos+2)%16], udp_dq_even[(2*pos+2)%16]} };
      tmp_dq_beat3 = { 4{udp_dq_odd[(2*pos+3)%16], udp_dq_even[(2*pos+3)%16]} };
    end
    else begin
      // lfsr or user program
      $display ("-> %0t: [BENCH] pattern check not supported yet on DX yet", $time);
    end

    if (gen_mask === 1'b1) begin
      tmp_dm_beat0 = 1'b0;
      tmp_dm_beat1 = ~tmp_dm_beat0;
    end
    else begin
      tmp_dm_beat0 = 1'b0;
      tmp_dm_beat1 = 1'b0;
    end
      
    // Check which signal has the last walking pattern...
    // ex: if lane_0 is used
    // Sequence goes like:  dq[7:0]    ->   dq[6:0], dq[7]       (for dq_r byte)
    //                      dq[15:8]   ->   dq[13:8], dq[15:14]  (for dq_f byte)
    //
    //                      dm[0]      ->   ~dm[0]               (for dm_r byte)
    //                      dm[1]      ->   ~dm[1]               (for dm_f byte)

    // no need to shift when in pos = 0, pattern shift depending on position
    if ((pattern == `PUB_DATA_WALKING_0) || (pattern == `PUB_DATA_WALKING_1)) begin
      for (i=1; i<=pos; i=i+1) begin
        tmp_dq_beat1[7:0] = {tmp_dq_beat1[6:0], tmp_dq_beat1[7]};
        tmp_dq_beat0[7:0] = {tmp_dq_beat0[6:0], tmp_dq_beat0[7]};
        tmp_dq_beat2[7:0] = {tmp_dq_beat0[6:0], tmp_dq_beat0[7]};
        tmp_dq_beat3[7:0] = {tmp_dq_beat1[6:0], tmp_dq_beat1[7]};
        if (gen_mask === 1'b1) begin
          if (i%2 == 0) begin
            tmp_dm_beat0 = tmp_dm_beat0;
            tmp_dm_beat1 = tmp_dm_beat1;
          end
          else begin
            tmp_dm_beat0 = ~tmp_dm_beat0;
            tmp_dm_beat1 = ~tmp_dm_beat1;
          end
        end
        else begin
          tmp_dm_beat0 = 1'b0;
          tmp_dm_beat1 = 1'b0;
        end
      end
    end

    if (pattern == `PUB_DATA_USER_PATTERN) begin 
      for (i=1; i<=pos; i=i+1) begin
        if (gen_mask === 1'b1) begin
          if (i%2 == 0) begin
            tmp_dm_beat0 = tmp_dm_beat0;
            tmp_dm_beat1 = tmp_dm_beat1;
          end
          else begin
            tmp_dm_beat0 = ~tmp_dm_beat0;
            tmp_dm_beat1 = ~tmp_dm_beat1;
          end
        end
        else begin
          tmp_dm_beat0 = 1'b0;
          tmp_dm_beat1 = 1'b0;
        end
      end
    end
      
    `ifdef DWC_WDBI_DDR4
      `ifdef DWC_WDBI_PHY
        `ifdef DWC_DX_DM_USE
          if (`GRM.bistrr[16]) begin  // Write data is inverted for WDBI iff DM pins are compiled in, MR5.WDBI is 1, PGCR3.WDBI is set && BISTRR.BDMEN is set
            if (count_1s(tmp_dq_beat0) > 4) tmp_dq_beat0_wdbi = ~tmp_dq_beat0;
            else                            tmp_dq_beat0_wdbi =  tmp_dq_beat0;
            if (count_1s(tmp_dq_beat1) > 4) tmp_dq_beat1_wdbi = ~tmp_dq_beat1;
            else                            tmp_dq_beat1_wdbi =  tmp_dq_beat1;
            cal_dq_pattern = { {`DWC_NO_OF_BYTES{tmp_dq_beat1_wdbi}}, {`DWC_NO_OF_BYTES{tmp_dq_beat0_wdbi}} };
          end
          else
            cal_dq_pattern = { {`DWC_NO_OF_BYTES{tmp_dq_beat1}}, {`DWC_NO_OF_BYTES{tmp_dq_beat0}} };
        `else
          `SYS.error;
          $display ("-> %0t: [BENCH]  ERROR: Illegal configuration - WDBI enabled but DM pins are not compiled in", $time;
        `endif
      `else
        cal_dq_pattern = { {`DWC_NO_OF_BYTES{tmp_dq_beat1}}, {`DWC_NO_OF_BYTES{tmp_dq_beat0}} };
      `endif
    `else
      cal_dq_pattern = { {`DWC_NO_OF_BYTES{tmp_dq_beat1}}, {`DWC_NO_OF_BYTES{tmp_dq_beat0}} };
    `endif

    // DM pins are compiled in
    `ifdef DWC_DX_DM_USE
      `ifdef DWC_WDBI_DDR4
        `ifdef DWC_WDBI_PHY
          if (`GRM.bistrr[16]) begin  // WBI sent out on DM pins iff MR5.WDBI is 1, PGCR3.WDBI is set && BISTRR.BDMEN is set
            if (count_1s(tmp_dq_beat0) > 4) tmp_dm_beat0_wdbi = ~tmp_dm_beat0;
            else                            tmp_dm_beat0_wdbi =  tmp_dm_beat0;
            if (count_1s(tmp_dq_beat1) > 4) tmp_dm_beat1_wdbi = ~tmp_dm_beat1;
            else                            tmp_dm_beat1_wdbi =  tmp_dm_beat1;
            cal_dm_pattern = { {`DWC_NO_OF_BYTES{tmp_dm_beat1_wdbi}}, {`DWC_NO_OF_BYTES{tmp_dm_beat0_wdbi}} };
          end
          else
            cal_dm_pattern = { {`DWC_NO_OF_BYTES{tmp_dm_beat1}}, {`DWC_NO_OF_BYTES{tmp_dm_beat0}} };
        `else
          cal_dm_pattern = { {`DWC_NO_OF_BYTES{tmp_dm_beat1}}, {`DWC_NO_OF_BYTES{tmp_dm_beat0}} };
        `endif
      `else
        cal_dm_pattern = { {`DWC_NO_OF_BYTES{tmp_dm_beat1}}, {`DWC_NO_OF_BYTES{tmp_dm_beat0}} };
      `endif
    // DM pins are NOT compiled in
    `else
      cal_dm_pattern = { {`DWC_NO_OF_BYTES{1'b0}}, {`DWC_NO_OF_BYTES{1'b0}} };
    `endif
  end
endtask

  
  // Count number of 1's is a byte
  function [4  - 1 : 0] count_1s;
    input [8   - 1 : 0] data_byte;

      integer           bit_idx;
      reg [4   - 1 : 0] cnt_1;

    begin
      cnt_1 = 4'd0; 
      for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) begin
        if (data_byte[bit_idx]) 
          cnt_1 = cnt_1 + 4'd1;
      end
      count_1s = cnt_1;
    end
  endfunction

//---------------------------------------------------------------------------
// Check pattern on DQ and DM
//---------------------------------------------------------------------------

wire dqs_redge_all;
wire dqs_fedge_all;

// When bubbles are enabled, slight differences in rise/fall edge times for the
// DQS signals have to be considered since we're checking the edge as well as
// the value
assign dqs_redge_all = &(`TB.dqs);
assign dqs_fedge_all = |(`TB.dqs);

always @(posedge dqs_redge_all, negedge dqs_fedge_all) begin: check_dx_lp_pattern
  event  e_dq_err;
  event  e_dm_err;
  
  if (check_dx_lp === 1'b1) begin
    if (`TB.dqs[`DWC_NO_OF_BYTES-1:0] == {`DWC_NO_OF_BYTES{1'b1}}) begin
      exp_dx_pattern_for_dqs(output_pos, pattern, exp_dq, exp_dm);
      output_pos = output_pos + 1;

      if (`TB.dq[`DWC_DATA_WIDTH-1:0] != exp_dq[`DWC_NO_OF_BYTES*8-1:0]) begin
        `SYS.error;
        $display ("-> %0t: [BENCH]  ERROR: mismatch DQ expected pattern `TB.dq = %0h  got  %0h", $time, exp_dq[`DWC_NO_OF_BYTES*8-1:0], `TB.dq[`DWC_DATA_WIDTH-1:0]);
        -> e_dq_err;
      end
      if (`TB.dm[`DWC_NO_OF_BYTES-1:0] != exp_dm[`DWC_NO_OF_BYTES-1:0]) begin
        `SYS.error;
        $display ("-> %0t: [BENCH]  ERROR: mismatch DM expected pattern `TB.dm = %0h  got  %0h", $time, exp_dm[`DWC_NO_OF_BYTES-1:0], `TB.dm[`DWC_NO_OF_BYTES-1:0]);
        -> e_dm_err;
      end 
    end       
    else begin
      if (`TB.dqs[`DWC_NO_OF_BYTES-1:0] == {`DWC_NO_OF_BYTES{1'b0}}) begin
        if (`TB.dq[`DWC_DATA_WIDTH-1:0] != exp_dq[`DWC_NO_OF_BYTES*8*2-1:`DWC_NO_OF_BYTES*8]) begin
          `SYS.error;
          $display ("-> %0t: [BENCH]  ERROR: mismatch DQ expected pattern `TB.dq = %0h  got  %0h", $time, exp_dq[`DWC_NO_OF_BYTES*8*2-1:`DWC_NO_OF_BYTES*8], `TB.dq[`DWC_DATA_WIDTH-1:0]);
          -> e_dq_err;
        end
        if (`TB.dm[`DWC_NO_OF_BYTES-1:0] != exp_dm[`DWC_NO_OF_BYTES*2-1:`DWC_NO_OF_BYTES]) begin
          `SYS.error;
          $display ("-> %0t: [BENCH]  ERROR: mismatch DM expected pattern `TB.dm = %0h  got  %0h", $time, exp_dm[`DWC_NO_OF_BYTES*2-1:`DWC_NO_OF_BYTES], `TB.dm[`DWC_NO_OF_BYTES-1:0]);
          -> e_dm_err;
        end 
  
        //output_pos = output_pos + 1;
      end
    end
    
  end
  else
    output_pos = 0;
  
end
    
