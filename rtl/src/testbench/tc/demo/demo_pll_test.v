//-----------------------------------------------------------------------------
//
// Copyright (c) 2010 Synopsys Incorporated.           
//                     
// This file contains confidential, proprietary information and trade    
// secrets of Synopsys. No part of this document may be used, reproduced   
// or transmitted in any form or by any means without prior written    
// permission of Synopsys Incorporated.            
// 
// DESCRIPTION: DDR PHY demonstration testcase
//-----------------------------------------------------------------------------
// PLL Digital and Analog Test Outputs Demo (demo_pll_test.v)
//-----------------------------------------------------------------------------
// This testcase demonstrates the use of the PLL digital and analog test output 
// (dto and ato) pins. Every PLL in the PHY is configured to direct its various 
// test signals to the top-level dto/ato in turn.

`timescale 1ns/1fs

`default_nettype none  // turn off implicit data types

`ifdef DWC_DDRPHY_PLL_TYPEB
`define PLLCRX_DEFAULT  `PLLCR0_DEFAULT;
`else
`define PLLCRX_DEFAULT  `PLLCR_DEFAULT;
`endif

module tc();

  //--------------------------------------------------------------------------//
  //   L o c a l    P a r a m e t e r s
  //--------------------------------------------------------------------------//

  localparam pDTC_NUM       = 6 
  ;
  localparam pATC_NUM       = 11  // 4'b000 - 4'b1010
  ;
  localparam pDTO           = 0; // ditial test outputs 
  localparam pATO           = 1; // analog   "     "
  localparam pREF_PRD       = `PUB_CLK_NX * `CLK_PRD; // ref clock (ctl_clk)
  localparam pNO_OF_PINS    = 3;
  localparam pNO_OF_PLLDTO  = 1 + `DWC_NO_OF_BYTES;// ac + max. byte lane #s (9)
  localparam pMNT_CLKS      = 5; // monitor over five clocks (samples 10 data)
  localparam pARRAY_SIZE    = 50*pMNT_CLKS;
  localparam pNDL_INS_DELAY = 0.420; // NDL insertion delay
  localparam pFXD_DELAY     = pNDL_INS_DELAY*2.0;//Fixed delay from AC clock gen
  localparam pDLYX1         = (`CLK_PRD); 
  localparam pDLYX2         = (`CLK_PRD/2.0); 
  localparam pDLYX4         = (`CLK_PRD/4.0); 
  localparam pDLYX8         = (`CLK_PRD/8.0);   
  localparam pMSG_IND       = 15; // message indention        
  reg [31:0] pllcr;
  
  //--------------------------------------------------------------------------//
  //   R e g i s t e r    a n d    W i r e    D e c l a r a t i o n s
  //--------------------------------------------------------------------------//

  integer                      pll_sel;
  integer                      pll_sel_max;  
  integer                      pll_signal_sel;
  integer                      pll_clk_sel;
  reg     [(100 * 8)  - 1 : 0] pll_sel_string;
  reg     [(100 * 8)  - 1 : 0] pll_signal_string;

  reg [8*pMSG_IND-1:0]         ind;
  integer                      test_no;
  integer                      dtc;    // digital test control
  integer                      atc;    // analog test control
  integer                      dtosel; // digital test output select
  integer                      atoen;  // analog test output enable
  wire                         dto_0;
  wire                         dto_1;
  wire                         ato;
  reg [0:pARRAY_SIZE-1]         dto_0_data;
  reg [0:pARRAY_SIZE-1]         dto_1_data;
  reg [0:pARRAY_SIZE-1]         ato_data;
  reg [31:0]                    dto_0_time [0:pARRAY_SIZE-1];
  reg [31:0]                    dto_1_time [0:pARRAY_SIZE-1];
  reg [31:0]                    ato_time   [0:pARRAY_SIZE-1];
  reg [1:0]                     pll_dto[0:`DWC_NO_OF_BYTES-1];
  reg                           pll_ato[0:`DWC_NO_OF_BYTES-1];
  reg                           pll_dto_0;
  reg                           pll_dto_1;
  reg                           mnt_en;
  integer                       dto_0_changes;
  integer                       dto_1_changes;
  integer                       ato_changes; 
  integer                       test_pin_no;
  integer                       k;
  real rclk_to_atoclk_dly;
  reg  rclk_to_atoclk_pos;
  real ato_edge_time;  
  genvar dwc_byte;

  //--------------------------------------------------------------------------//
  //   T e s t b e n c h    I n s t a n t i a t i o n
  //--------------------------------------------------------------------------//
  ddr_tb ddr_tb();

  //--------------------------------------------------------------------------//
  //   T e s t    S t i m u l u s
  //--------------------------------------------------------------------------//

  initial begin
      // Workaround race condition with initial block from system.v
      #1;
      mnt_en  = 1'b0;

      // Unit -12 1ps, precision -15 1fs, suffix is ps, width is min number of character to display
      $timeformat(-12, 3, "ps", 10);

      `ifndef DWC_DDRPHY_PLL_USE
      $display("-> %0t: [BENCH] must not run test case with -nopll option", $time);
      `END_SIMULATION;
      `endif

      // this testcase will set its own training
      `SYS.rdimm_auto_train_en    = 1'b0;
    
      // Initialization
      `SYS.power_up;

      //------------------------------------------------------------------------
      // Reset PLL to default setting

      $display("-> %0t: [BENCH] Set PLL control to default value", $time);
      `GRM.pllcr = `PLLCRX_DEFAULT;
      `ifdef DWC_PLL_BYPASS
      `GRM.pllcr[31] = 1'b1;
      `endif
   
      `CFG.write_register(`PLLCR, `GRM.pllcr);
      
      // unset power down 
      `GRM.dsgcr[14:13] = 2'b00;
      `CFG.write_register(`DSGCR, `GRM.dsgcr);

      //------------------------------------------------------------------------
      // Cycle through all possible PLL test signals that can be directed to
      // the top-level dto pins
      test_no = pDTO;
      $display("********************************************************************");
      $display("-> %0t: [BENCH] Start test_no = pDTO (digital test output)", $time);
      $display("********************************************************************");
      for (pll_clk_sel = 0; pll_clk_sel < pDTC_NUM; pll_clk_sel = pll_clk_sel + 1) begin

        case (pll_clk_sel)
          0 : pll_sel_string = "PLL test output is disabled";
          1 : pll_sel_string = "PLL test output is x1 clock";
          2 : pll_sel_string = "PLL test output is reference clock";
          3 : pll_sel_string = "PLL test output is feedback clock";
          4 : pll_sel_string = "PLL lock detect output";
          5 : pll_sel_string = "PLL lock counter enable";
        endcase // case(pll_clk_sel)

        $display("-> %0t: [BENCH] ", $time);
        $display("-> %0t: [BENCH] ----------------------------------------------", $time);
        $display("-> %0t: [BENCH] %0s", $time, pll_sel_string);
        `GRM.pllcr[2:0] = pll_clk_sel;
        `CFG.write_register(`PLLCR, `GRM.pllcr);
        `SYS.nops(4);

        //----------------------------------------------------------------------
        // Cycle through all available PLLs: number of DATX8s + AC
      if (|`DWC_DX_AC_PLL_SHARE)
        pll_sel_max = `NO_OF_BYTES;
      else
        pll_sel_max = 1 + `NO_OF_BYTES;

        for (pll_sel = 0; pll_sel <  pll_sel_max; pll_sel = pll_sel + 1) begin
          if(`GRM.dx_pll_share[pll_sel]) begin 
            // AC select = `NO_OF_BYTES
            if (pll_sel == `NO_OF_BYTES) begin
              $display("-> %0t: [BENCH] Select AC PLL dto", $time);
              `GRM.pgcr0[18:14] = 5'b01001;
            end
            // DATX8 select = 0 to (`NO_OF_BYTES - 1)
            else begin
              $display("-> %0t: [BENCH] Select DATX8 %0d PLL dto", $time, pll_sel);
              `GRM.pgcr0[18:14] = 5'b00000 + pll_sel;
            end
            `CFG.write_register(`PGCR0, `GRM.pgcr0);
            
            // enable outputs
            `GRM.dsgcr[17:16] = 2'b11;
            `CFG.write_register(`DSGCR, `GRM.dsgcr);

            // Allow some time to view dto
            `SYS.nops(500);

            // verify the test outputs
            dtc    = pll_clk_sel;
            dtosel = pll_sel;
            atc    = 0;
            $display("-> %0t: [BENCH] pDTO, call monitor_pll_adto - dtosel = 'b%0b, dtc = 'b%0b", $time, dtosel, dtc);
            monitor_pll_adto(dtc, dtosel, atc);
            `SYS.nops(10); // to complete monitoring
          end 
        end // for (pll_sel = 0; pll_sel < (`NO_OF_BYTES + 1); pll_sel = pll_sel + 1)
      end // for (pll_clk_sel = 0; pll_clk_sel < pDTC_NUM; pll_clk_sel = pll_clk_sel + 1)

      //------------------------------------------------------------------------
      // the ato is in high resistance when PLL is bypassed
`ifndef DWC_PLL_BYPASS
      // Reset PLL to default setting

      $display("-> %0t: [BENCH] ", $time);
      $display("-> %0t: [BENCH] ", $time);
      $display("-> %0t: [BENCH] Set PLL control to default value", $time);
      `GRM.pllcr = `PLLCRX_DEFAULT;

      `CFG.write_register(`PLLCR, `GRM.pllcr);

      //------------------------------------------------------------------------
      // Cycle through all available PLLs: number of DATX8s + AC

      test_no = pATO;
      $display("********************************************************************");
      $display("-> %0t: [BENCH] Start test_no = pATO (analog test output)", $time);
      $display("********************************************************************");
      if (|`DWC_DX_AC_PLL_SHARE)
        pll_sel_max = 1;
      else
        pll_sel_max = 2 + `NO_OF_BYTES;
 
      for (pll_sel = 0; pll_sel < pll_sel_max; pll_sel = pll_sel + 1) begin

        case (pll_sel)
          0 : pll_sel_string = "All PLL analog test signals are tri-stated";
          1 : pll_sel_string = "AC PLL analog test output selected";
          default : pll_sel_string = "analog test output selected";
        endcase // case(pll_sel)
        if((pll_sel > 1 ?`GRM.dx_pll_share[pll_sel-2]:1)) begin
        $display("-> %0t: [BENCH] ", $time);
        $display("-> %0t: [BENCH] ----------------------------------------------", $time);
        if (pll_sel > 1) $display("-> %0t: [BENCH] DATX8 %0d %0s", $time, (pll_sel - 2), pll_sel_string);
        else             $display("-> %0t: [BENCH] %0s", $time, pll_sel_string);
      `ifdef DWC_DDRPHY_PLL_TYPEB
        `GRM.pllcr[11:8] = 4'b0000 + pll_sel;
      `else
        `GRM.pllcr[10:7] = 4'b0000 + pll_sel;
      `endif
        `CFG.write_register(`PLLCR, `GRM.pllcr);
        `SYS.nops(4);

        //------------------------------------------------------------------------
        // Cycle through all possible PLL analog test signals that can be directed
        // to the top-level ato pin

        pll_signal_sel = 1;  // Start with the first valid PLL signal selection

        while (pll_signal_sel < pATC_NUM) begin

          case (pll_signal_sel)
            4'b0000 : pll_signal_string = "No signal";
            4'b0001 : pll_signal_string = "vdd_ckin";
            4'b0010 : pll_signal_string = "vrfbf";
            4'b0011 : pll_signal_string = "vdd_cko";
            4'b0100 : pll_signal_string = "vp_cp";
            4'b0101 : pll_signal_string = "vpfil(vp)";
            4'b0110 : pll_signal_string = "No signal";
            4'b0111 : pll_signal_string = "gd";
            4'b1000 : pll_signal_string = "vcntrl_atb";
            4'b1001 : pll_signal_string = "vref_atb";
            4'b1010 : pll_signal_string = "vpsf_atb";
            default : pll_signal_string = "Reserved";
          endcase // case(pll_signal_sel)
           $display("-> %0t: [BENCH] %0s signal selected", $time, pll_signal_string);
      `ifdef DWC_DDRPHY_PLL_TYPEB
          `GRM.pllcr[7:4] = pll_signal_sel;
      `else
          `GRM.pllcr[6:3] = pll_signal_sel;
      `endif
          `CFG.write_register(`PLLCR, `GRM.pllcr);

          // Allow some time to view ato
          `SYS.nops(500);

          // verify the test outputs
          dtc    = 0;
          dtosel = 0;
          atoen  = pll_sel;
          atc    = pll_signal_sel;
          $display("-> %0t: [BENCH] pATO, call monitor_pll_adto - atoen = 'b%0b, atc = 'b%0b", $time, atoen, atc);
          monitor_pll_adto(dtc, dtosel, atc);
          `SYS.nops(10); // to complete monitoring

          // Go on to next PLL signal
          if (pll_signal_sel == 4'b0101) pll_signal_sel = 4'b0111; // Skip invalid selection
          else                           pll_signal_sel = pll_signal_sel + 1;

         end
        end

      end // for (pll_sel = 0; pll_sel < (2 + `NO_OF_BYTES); pll_sel = pll_sel + 1)
   
`endif
      //------------------------------------------------------------------------
      // Reset PLL to default setting

      $display("-> %0t: [BENCH] ", $time);
      $display("-> %0t: [BENCH] ", $time);
      $display("-> %0t: [BENCH] Set PLL control to default value", $time);
      `GRM.pllcr = `PLLCRX_DEFAULT;
      `ifdef DWC_PLL_BYPASS
      `GRM.pllcr[31] = 1'b1;
      `endif
      `CFG.write_register(`PLLCR, `GRM.pllcr);

      `END_SIMULATION;

  end // initial begin

  //--------------------------------------------------------------------------//
  //                                T A S K S
  //--------------------------------------------------------------------------//

  // pll monitor
  // -----------
  // monitors the status of the PLL functional outputs
`ifdef DWC_PHY_DTO_USE
  assign dto_0 = `CHIP.dto[0];               
  assign dto_1 = `CHIP.dto[1];  

  // pll digital test outputs at chip
  always @(dto_0)
    begin
      if (mnt_en === 1'b1)
        begin
          dto_0_data[dto_0_changes] = dto_0;
          dto_0_time[dto_0_changes] = 1000*($realtime); // ps
          dto_0_changes = dto_0_changes + 1;
        end
    end
  always @(dto_1)
    begin
      if (mnt_en === 1'b1)
        begin
          dto_1_data[dto_1_changes] = dto_1;
          dto_1_time[dto_1_changes] = 1000*($realtime); // ps
          dto_1_changes = dto_1_changes + 1;
        end
    end
`endif    
`ifdef DWC_PHY_ATO_USE  
  // analog test output at chip               
  assign ato   = `CHIP.ato;
  always @(ato)
    begin
      if (mnt_en === 1'b1)
        begin
          ato_data[ato_changes] = ato;
          ato_time[ato_changes] = 1000*($realtime); // ps
          ato_changes = ato_changes + 1;
        end
    end
`endif

  // verify monitor outputs
  // ----------------------
  // verifies that the changes on the PLL test outputs are correct
  task monitor_pll_adto;
    input [2:0] dtc;    // digital test control selects
    input [4:0] dtosel; // digital test output selects
    input [3:0] atc;    // analog test control selects
    begin
      // reset test output change counters and enable monitoring of outputs
      dto_0_changes    = 0;
      dto_1_changes    = 0;
      ato_changes      = 0;
      
      // wait for 100 nops. used to be 5 nops but during CSDR JTAG tests, the mnt_en was
      // being set as the dto/ato signals were being programmed. this will ensure that the
      // dto/ato signals are programmed, then the monitor will get the dto/ato pin values.
      `CFG.nops(100);

      // monitor the status of pll test outputs
      get_pll_adto_pins;

      // enable monitor
      @(posedge `AC_TOP.ctl_clk);
      mnt_en = 1'b1;
      repeat (pMNT_CLKS) @(posedge `AC_TOP.ctl_clk);
      // disable monitor
      mnt_en = 1'b0;
      
      for (test_pin_no=0; test_pin_no<pNO_OF_PINS; test_pin_no=test_pin_no+1)
        begin
          // verify test outputs
          verify_test_output(test_pin_no, dtc, dtosel, atc);
        end

      $display("-> %0t: [BENCH] Done with monitor_pll_adto()", $time);
    end
  endtask // monitor_pll_adto

  // verify test pin
  task verify_test_output;
    input [1:0]     test_pin_no;
    input [2:0]     dtc;
    input [4:0]     dtosel;
    input [3:0]     atc;
    reg [8*10-1:0]  test_pin;
    reg [8*40-1:0]  atc_pin;
    reg [8*100-1:0] atc_msg;
    reg             test_out;
    reg             test_data;
    integer         changes;
    integer         xpctd_changes;
    integer         j;
    realtime        xpctd_dly;
    realtime        xpctd_tHI;
    realtime        xpctd_tLO;
    realtime        test_time;
    realtime        t_tmp;
    realtime        prev_test_time;
    realtime        pulse_width;
    realtime        tERR;
    realtime        tHI;
    realtime        tLO;
    realtime        tdly;
    event           e_PHY_CTL_CLK;
    event           e_TEST_ATO_DTO_CLK;
    begin
      $display("%0t => inside verify_test_output() - dtc=%0d, dtosel=%0d, atc=%0d, test_pin_no = %0d",$time, dtc,dtosel,atc, test_pin_no);
      
      tERR = 0.001; // 1 ps error accepted in pulse width calculation
      // TBD ** might be greater for sdf gate-level simulation

      $display("-> %0t: [BENCH] check test_pin_no = 2'b%0b", $time, test_pin_no);
      case (test_pin_no)
        0: begin
          // digital test output 0; always outputs clock input
          test_pin = "dto[0]";
          test_out = dto_0;
          changes  = dto_0_changes;
          if (dtc == 0)
            xpctd_changes = 0.0;
          else
`ifndef DWC_AC_DTO_USE
  `ifndef DWC_DX_DTO_USE
              xpctd_changes = 0.0;
  `else          
              xpctd_changes = 2*pMNT_CLKS;
  `endif
`else
              xpctd_changes = 2*pMNT_CLKS;
`endif          

`ifdef DWC_PLL_BYPASS
            xpctd_changes = 0.0;
`endif          

          xpctd_tHI = pREF_PRD/2.0;
          xpctd_tLO = pREF_PRD/2.0;
          xpctd_dly = 0.0;
          $display("-> %0t: [BENCH] ,zhliu debug0 dto_0_changes=%d , changes = %0d, xpctd_changes = %0d, test_pin_no = %0d", $time, dto_0_changes,changes, xpctd_changes, test_pin_no);
       
        end
        1: begin
          // digital test output; outputs different signals
          test_pin = "pll_dto[1]";
          test_out = dto_1;
          changes  = dto_1_changes;
          if ((dtc == 0) | (dtc > 3))
            xpctd_changes = 0.0;
          else
`ifndef DWC_AC_DTO_USE
  `ifndef DWC_DX_DTO_USE
              xpctd_changes = 0.0;
  `else          
              xpctd_changes = 2*pMNT_CLKS;
  `endif
`else
              xpctd_changes = 2*pMNT_CLKS;
`endif          
          xpctd_tHI = pREF_PRD/2.0;
          xpctd_tLO = pREF_PRD/2.0;
          case (dtc)
            0, 6, 7: xpctd_dly = 0.0;
            1: begin
                 if (`GRM.rr_mode == 1'b1)
                   xpctd_dly = 0.0;
                 else
                   xpctd_dly = pDLYX1;
               end
            2: begin
              `ifdef DWC_PLL_BYPASS
               xpctd_changes = 0.0;
              `endif 
               xpctd_dly = 0.0; 
               end
            3: xpctd_dly = 0.0;
          endcase // case(dtc)
        end
        2: begin
          // analog test output; outputs different signals
          test_pin = "pll_ato";
          test_out = ato;
          changes  = ato_changes;
          atc_pin  = "ATC";
          casez (atc)
            0, 6, 11, 12, 13, 14, 15: // reserved bits
              begin
                atc_msg = "Reserved";
                xpctd_changes = 0;
              end
            1: // modeled as 1*pllin_x1
              begin
                atc_msg = "vdd_ckin";
                xpctd_changes = 2*pMNT_CLKS;
                xpctd_tHI = pREF_PRD/2.0;
                xpctd_tLO = pREF_PRD/2.0;
                if (`GRM.rr_mode == 1'b1)
                  xpctd_dly = 0.0;
                else
                  xpctd_dly = pDLYX1;
              end
            2:  // modeled as -1*pllin_x1
              begin
                atc_msg = "vrfbf";
                xpctd_changes = 2*pMNT_CLKS;
                xpctd_tHI = pREF_PRD/2.0;
                xpctd_tLO = pREF_PRD/2.0;
                if (`GRM.rr_mode == 1'b1)
                  xpctd_dly = pDLYX1;
                else
                  xpctd_dly = 0.0;
              end
            3: // modeled as 1*pllin_x1
              begin
                atc_msg = "vdd_cko";
                xpctd_changes = 2.0*pMNT_CLKS;
                xpctd_tHI = pREF_PRD/2.0;
                xpctd_tLO = pREF_PRD/2.0;
                if (`GRM.rr_mode == 1'b1)
                  xpctd_dly = 0.0;
                else
                  xpctd_dly = pDLYX1;
              end
            4: // modeled as -1*pllin_x1
              begin
                atc_msg = "vp_cp";
                xpctd_changes = 2.0*pMNT_CLKS; // sdr ac
                xpctd_tHI = pREF_PRD/2.0;
                xpctd_tLO = pREF_PRD/2.0;
                if (`GRM.rr_mode == 1'b1)
                  xpctd_dly = pDLYX1;
                else
                  xpctd_dly = 0.0;
              end
            5: // modeled as 4*pllin_x1
              begin
                atc_msg = "vpfil(vp)";
                xpctd_changes = 4.0*2*pMNT_CLKS;
                xpctd_tHI = pREF_PRD/8.0;
                xpctd_tLO = pREF_PRD/8.0;

                // TODO - review this
                if(rclk_to_atoclk_pos == 1'b1) begin
                  $display("-> %0t: [BENCH] pll_analog_test is before ref clock, 1/2 clock compensation", $time);
                  xpctd_dly = xpctd_dly + (`CLK_PRD/2.0);
                end
              end
            7: // modelled as ground (ie, gd or VSS)
              begin
                atc_msg = "gd";
                xpctd_changes = 0;
              end
            8: // modelled as -4*pllin_x1
              begin
                atc_msg = "vcntrl_atb";
                if (`TCLK_PRD >= `CLK_PRD)
                  xpctd_changes = 4.07*2*pMNT_CLKS;
                else
                  xpctd_changes = 4.1*2*pMNT_CLKS;
                xpctd_tHI = pREF_PRD/8.0;
                xpctd_tLO = pREF_PRD/8.0;
                xpctd_dly = pDLYX4;
              end
            9: // modelled as 8*pllin_x1
              begin
                atc_msg = "vref_atb";
                xpctd_changes = 4.0*4*pMNT_CLKS; 
                xpctd_tHI = pREF_PRD/16.0;
                xpctd_tLO = pREF_PRD/16.0;
                if(rclk_to_atoclk_pos == 1'b1) begin
                  $display("-> %0t: [BENCH] pll_analog_test is before ref clock, 1/2 clock compensation", $time);
                  xpctd_dly = xpctd_dly + (`CLK_PRD/4.0);
                end
              end
            10: // modelled as -8*pllin_x1
              begin
                atc_msg= "vpsf_atb";
                xpctd_changes = 4.0*4*pMNT_CLKS;
                xpctd_tHI = pREF_PRD/16.0;
                xpctd_tLO = pREF_PRD/16.0;
                xpctd_dly = pDLYX8;
              end
          endcase // casez(atc)
`ifndef DWC_AC_ATO_USE          
  `ifndef DWC_DX_ATO_USE 
            xpctd_changes = 0;
  `endif
`endif          
          $display("-> %0t: [BENCH] ,zhliu debug changes = %0d, xpctd_changes = %0d, test_pin_no = %0d", $time, changes, xpctd_changes, test_pin_no);
        end // case: 2
      endcase // case(test_pin_no)

      // test_no is a var in the main() block of the test case and is either pDTO or pATO (digital or analog)
      // report dto on test pin 0 & 1; ato on test pin 2
      if ((test_no == pDTO && test_pin_no == 0 )
          || (test_no == pDTO && test_pin_no == 1)
          || (test_no == pATO && test_pin_no == 2)
          )
        begin
          if (test_no == pDTO)
            begin
              $write("\n==> Setting digital test control (DTC) to ");
              case (dtc)
                0:
                  begin
                    $write("[%b] = '0' (Test ouput is ", dtc);
                    $display("disabled) ");
                  end
                1:  $display("[%b] = PLL x1 clock (X1) ", dtc);
                2:
                  begin
                    $write("[%b] = PLL reference (input) clock ", dtc);
                    $display("(REF_CLK) ");
                  end
                3:
                  begin
                    $write("[%b] = PLL feedback clock ", dtc);
                    $display("(FB_X1) ");
                  end
                4: begin
                    xpctd_changes = 0;
                    $write("[%b] = PLL lock detect output ", dtc);
                    $display("(pll_lock) ");
                  end
                5: begin
                    xpctd_changes = 0;
                    $write("[%b] = PLL lock counter enable ", dtc);
                    $display("(en_count) ");
                  end 
                6, 7: begin
                    $write("[%b] = Reserved", dtc);
                    $display("(Reserved) ");
                  end 
              endcase // case(dtc)
              $display("");
            end

          // verify changes on PLL test output
          $write("-> %0t: Verifying test pin %0s - ", $realtime, test_pin);
          case (test_no)
            pDTO: begin 
                    if (dtosel == `DWC_NO_OF_BYTES) 
                      $display("AC PLL digital test output ...\n");
                    else
                      begin
                        $display("DATX8 byte %0d PLL digital ", dtosel);
                        $display("test output ...\n");
                      end
            end
            pATO: begin
                    case (atoen)
                      4'b0000: begin
                                 $display("ALL PLL analog test signals ");
                                 $write("are tri-stated ");
                      end
                      4'b0001: $write("AC ");
                      default: $write("DATX8 byte %0d ", atoen-2);
                    endcase // case(atoen)
              
                    if (atoen !=0)
                      begin
                        $display("PLL analog test ");
                        $write("signal is driven out ");
                      end
                    $display("for %0s %b (%0s) ...\n", atc_pin, atc, atc_msg);
            end
          endcase // case(test_no)

          $display("-> %0t: [BENCH] atoen = %0d, atc = %0d, changes = %0d, xpctd_changes = %0d, test_pin_no = %0d",
                    $time, atoen, atc, changes, xpctd_changes, test_pin_no);

          if ( test_no == pATO && 
               (atoen == 0 || atc == 0 || atc == 6 || atc == 11 || atc == 12
                || atc == 13 || atc == 14 || atc == 15))
            $display("%s- Test output is tri-stated (output = %b)\n",ind, 
                     test_out);
          else if (changes == 0 && xpctd_changes != 0)
            begin
              `SYS.log_error;
              $display("%s*** ERROR: No change on test output", ind);
            end
          else if (changes == 0)
            begin
              $display("%s- No change on test output (output = %b)", ind,
                       test_out);
            end
          else
            begin
              // check correct signal by delay relative to clock input
              @(posedge `PHY.ctl_clk);
              test_time = $realtime;
              -> e_PHY_CTL_CLK;
              $display(" at %0t: test_time = %0t.... ", $realtime, test_time);
              
              case (test_pin_no)
                0:  @(posedge dto_0);
                1:  @(posedge dto_1);
                2:  @(posedge ato);
              endcase // case(test_pin_no)
              -> e_TEST_ATO_DTO_CLK;
              $display(" at %0t: test pin sample time = %0t.... ", $realtime, $realtime);

              tdly = $realtime - test_time;
              $display(" tdly = %0t.... ", tdly);
              
              // For case that the expected delay is not zero, sample for the next edge.
              if (xpctd_dly > 0 && (tdly < tERR)) begin
                case (test_pin_no)
                  0:  @(posedge dto_0);
                  1:  @(posedge dto_1);
                  2:  @(posedge ato);
                endcase // case(test_pin_no)
                -> e_TEST_ATO_DTO_CLK;
                $display(" at %0t: test pin sample time = %0t.... ", $realtime, $realtime);

                tdly = $realtime - test_time;
                $display(" tdly = %0t.... ", tdly);
              end                
              
               //$display("[DEBUG] Delta between posedge PHY.ctl_clk and posedge of ato, tdly = %0f", tdly);
              
              // for case when tdly is close just smaller than PRD and within tERR margin
              if ((pREF_PRD - tdly > 0.000 ) && (pREF_PRD - tdly < tERR) && xpctd_dly == 0) begin
                tdly = pREF_PRD - tdly;
              end              

              // for case when test_pin is early but tdly is close just smaller than PRD and within tERR margin
              if ((tdly - pREF_PRD > 0.000 ) && (tdly - pREF_PRD < tERR) && xpctd_dly == 0) begin
                tdly = tdly - pREF_PRD;
              end  

              // for case when test_pin is early but tdly is close just smaller than PRD and within tERR margin
              if (test_no == pATO && (atc == 5 || atc == 8)) begin
                if ((tdly - (pREF_PRD/4.0) > 0.000 ) && (tdly - (pREF_PRD/4.0) < tERR) && xpctd_dly == 0) begin
                  tdly = tdly - (pREF_PRD/4.0);
                end
                else begin
                  if ((pREF_PRD/4.0 - tdly > 0.000 ) && (pREF_PRD/4.0 - tdly < tERR) && xpctd_dly == 0) begin
                    tdly = (pREF_PRD/4.0) - tdly;
                  end
                end
              end  
              
              // for case when test_pin is early but tdly is close just smaller than PRD and within tERR margin
              if (test_no == pATO && (atc == 9 || atc == 10)) begin
                if ((tdly - (pREF_PRD/8.0) > 0.000 ) && (tdly - (pREF_PRD/8.0) < tERR) && xpctd_dly == 0) begin
                  tdly = tdly - (pREF_PRD/8.0);
                end
                else begin
                  if ((pREF_PRD/8.0 - tdly > 0.000 ) && (pREF_PRD/8.0 - tdly < tERR) && xpctd_dly == 0) begin
                    tdly = (pREF_PRD/8.0) - tdly;
                  end
                end
              end  
              
              t_tmp = (pREF_PRD/2.0 + tERR);
              if (tdly > (pREF_PRD/2.0 + tERR)) begin
                $display(" tdly = %0t.... ", tdly);
                $display(" pREF_PRD/2.0 + tERR = %0t.... ", t_tmp);
                tdly = tdly - pREF_PRD/2.0;
                $display(" tdly = %0t.... ", tdly);
              end

              // Revise expected delay in case there is a built-in instrinsic
              // delay and/or the expected delay is greater than a clock period
              if (xpctd_dly > pREF_PRD/2.0) begin
                xpctd_dly = xpctd_dly - pREF_PRD/2.0;
                $display(" xpctd_dly = %0t.... ", xpctd_dly);
              end

              // compare tdly to expected delay calculated above
              if ((tdly < (xpctd_dly - tERR)) || (tdly > (xpctd_dly + tERR)))
                begin
                  `SYS.log_error;
                  $write("    *** ERROR: Wrong delay (%0t) relative to", tdly);
                  $display(" Ref CLK; expected %0t  at $realtime %0t", xpctd_dly, $realtime);
                end

              // print and verify changes
              for (j=0; j<changes; j=j+1)
                begin
                  case (test_pin_no)
                    0: begin
                         test_data = dto_0_data[j];
                         test_time = dto_0_time[j]/1000.0;
                    end
                    1: begin
                         test_data = dto_1_data[j];
                         test_time = dto_1_time[j]/1000.0;
                    end
                    2: begin
                         test_data = ato_data[j];
                         test_time = ato_time[j]/1000.0;
                    end
                  endcase // case(test_pin_no)

                  $display("%s- %s changed to %b at %0t", ind, test_pin,
                           test_data, test_time);

                  // check correct signal by pulse widths
                  if (j != 0)
                    begin
                      pulse_width = test_time - prev_test_time;
                      if (test_data === 1'b0) tHI = pulse_width;
                      if  (test_data === 1'b1) tLO = pulse_width;
                      if  ((test_data === 1'b0) &&
                           ((pulse_width < (xpctd_tHI - tERR)) ||
                            (pulse_width > (xpctd_tHI + tERR))))
                        begin
                          `SYS.log_error;
                          $write("    *** ERROR: Wrong high time (%0t);", 
                                 pulse_width);
                          $display(" expected %0t", xpctd_tHI);
                        end
                      if  ( (test_data === 1'b1) &&
                            ( (pulse_width < (xpctd_tLO - tERR)) ||
                              (pulse_width > (xpctd_tLO + tERR))))
                        begin
                          `SYS.log_error;
                          $write("    *** ERROR: Wrong low time (%0t);",
                                 pulse_width);
                          $display(" expected %0t", xpctd_tLO);
                        end
                    end
                  prev_test_time = test_time;
                end // for (j=0; j<changes; j=j+1)

              // check if enough signal changes
              if  ((changes > 0) && 
                   ( (changes < (xpctd_changes - 2)) ||
                     (changes > (xpctd_changes + 2)))
                   )
                begin
                  `SYS.log_error;
                  $write("    *** ERROR: Test output changed ");
                  $display("%0d times; expected %0d", changes, xpctd_changes);
                end
              else
                begin
                  $display("");
                  $display("%s- Test output changed %0d times", ind,changes);
                end

              $display("%s- Test output high pulse width      = %0t",ind,tHI);
              $display("%s- Test output low pulse width       = %0t",ind,tLO);
              $display("%s- Test output delay from ctl_clk    = %0t",ind,tdly);
            end // else: !if(changes == 0)
        end // if ((test_no == pDTO && test_pin_no == 0 )...

      $display("");
      $display("-> %0t: [BENCH] Done with verify_test_output()", $time);
    end
  endtask // verify_test_output

  task get_pll_adto_pins;
    begin
      $display("%0t => inside get_pll_adto_pins() to collect either dto or ato values", $time);
      case (test_no)
        pDTO: // report pll_dto pin status at every block
          begin
            $write("\n=> Forcing to disable unselected pins for PLL ");
            $write("digital test outputs (pll_dto) ...\n\n");
            //$display("at %0t ...\n", $realtime);
            $display("%s          status at PHY%s status at CHIP", ind, ind);
            $write("%s---------------------------------", ind);
            $display("      --------------");
            begin
              for (k=0; k<`DWC_NO_OF_BYTES; k=k+1)
                begin
                  // report status of pll_dto pins on every block
                  #(pREF_PRD/16);
                  {pll_dto_1, pll_dto_0} = pll_dto[k];
                  $write("%sDATX8 byte %0d    pll_dto[1:0] = ", ind, k);
                  if (k==0)
                    begin
                      $write("%b%b     ", pll_dto_1, pll_dto_0,);
                      $display("dto[1:0] = %b%b", dto_1, dto_0);
                    end
                  else
                    begin
                      $display("%b%b     ", pll_dto_1, pll_dto_0,);
                    end
                end
              $write("%sAC              pll_dto[1:0] = ", ind);
              $display("%b", `AC_TOP.ac_pll_dto[1:0]);
            end
          end
        pATO: // report pll_ato pin status at every clock
          begin
            $write("\n==> Checking status on all PLL analog test outputs");
            $display(" (pll_ato) at %0t ...\n", $realtime);
            $display("%s      status at PHY%sstatus at CHIP", ind, ind);
            $display("%s--------------------------        --------------",ind);
            $write("%sAC             pll_ato = %b", ind, `AC_TOP.ac_pll_ato);
            $display("           ato = %0d", ato);
            for (k=0; k<`DWC_NO_OF_BYTES; k=k+1) 
              begin
                $display("%sDATX8 byte %0d   pll_ato = %0d ",ind,k,pll_ato[k]);
              end
          end
      endcase // case(test_no)
    end
  endtask // get_pll_adto_pins
  
  // enable pll_dto pins only for one byte lane
  generate
    for(dwc_byte=0; dwc_byte<`DWC_NO_OF_BYTES; dwc_byte=dwc_byte+1) 
      begin: force_pins
        always @(posedge mnt_en)
          begin
            if (dwc_byte != dtosel)
              force `PHY.dx_pll_dto[1+(2*dwc_byte):(2*dwc_byte)] = 2'b00;
          end
      end
  endgenerate

  generate
    for(dwc_byte=0; dwc_byte<`DWC_NO_OF_BYTES; dwc_byte=dwc_byte+1) 
      begin: release_pins
        always @(negedge mnt_en)
          release `PHY.dx_pll_dto[1+(2*dwc_byte):(2*dwc_byte)] ;
      end
  endgenerate

  // enable ac pll_dto pins only
  always @(posedge mnt_en)
    begin
      if (dtosel != `DWC_NO_OF_BYTES)
        force `AC_TOP.ac_pll_dto[1:0]=2'b00;
    end

  always @(negedge mnt_en)
    begin
      release `AC_TOP.ac_pll_dto[1:0];
    end

  // probe and check status of digital test output pins 
  generate
    for(dwc_byte=0; dwc_byte<`DWC_NO_OF_BYTES; dwc_byte=dwc_byte+1) 
      begin: pll_dto_pin_gen
        always @(*)
          pll_dto[dwc_byte] 
           = {`DXn_top.dx_pll_dto[1],
              `DXn_top.dx_pll_dto[0]};
      end
  endgenerate

  // probe and check status of analog test output pins
  generate
    for(dwc_byte=0; dwc_byte<`DWC_NO_OF_BYTES; dwc_byte=dwc_byte+1) 
      begin: pll_ato_pin_gen
        always @(*)
          pll_ato[dwc_byte]=`DXn_top.dx_pll_ato;
    end
  endgenerate

  // this block will monitor `CHIP.clk ref_clk to `CHIP.ato signal, looking for
  // when posedge of ref_clk, is the last edge of the pll_analog_test signal before or
  // after the ref_clk?
  // -> if before, need to compensate for expected delay (0.5*CLK_PRD, 0.25*CLK_PRD, 0.125*CLK_PRD)
  // -> if after, no need to compensate the expected delay
  always @(posedge `CHIP.clk) begin
    rclk_to_atoclk_dly = $realtime - ato_edge_time;

    // check the value of the difference between rclk and atoclk:
    // - a delta of <50ps means the atoclk transitioned right before the rclk
    // - a delta of >50ps means the atoclk transitioned a while back and there's another transition
    //    going to happen after rclk (probably w/in 50ps of the posedege of rclk)
    if(rclk_to_atoclk_dly*1000.0 < 0.050)
      // atoclk transitioned very close to rclk
      rclk_to_atoclk_pos = 1;
    else
      // atoclk did not transition very close to rclk, so it probably will after posedge of rclk
      rclk_to_atoclk_pos = 0;
  end
    
`ifdef DWC_PHY_ATO_USE  
  always @(`CHIP.ato) begin
    ato_edge_time = $realtime;
  end
`endif

endmodule // tc

`default_nettype wire  // restore implicit data types

