/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Modules to tranform bus signals into radix encoded signals    *
 *              for easy viewing in VirSim                                    *
 *                                                                            *
 *****************************************************************************/

module ddr_radix(/*AUTOARG*/
                 // Inputs
                 clk, m_cke, m_cs_n, m_ras_n, m_cas_n, m_we_n, m_ba, m_a 
                 );

  // controller parameters
  parameter rank_max = `DDR_RANK_WIDTH; 
  parameter raw      = `DDR_ROW_WIDTH;
  parameter caw      = `DDR_COL_WIDTH;

  // constants
  localparam nk_max  = 4;  // to simplify connection some of the outputs to the PHY are fully expanded
  localparam baw_max = 3;
  localparam raw_max = 16;
  
  input     clk;
  input [nk_max-1:0] m_cke;
  input [nk_max-1:0] m_cs_n;
  input              m_ras_n;
  input              m_cas_n;
  input              m_we_n;
  input [baw_max-1:0] m_ba;
  input [raw_max-1:0] m_a;

  // internals
  parameter           DES     = 0;
  parameter           NOP     = 1;
  parameter           R       = 2;
  parameter           W       = 3;
  parameter           P       = 4;
  parameter           A       = 5;
  parameter           REF     = 6;
  parameter           MRS     = 7;
  parameter           SRE     = 8; //self-refresh entry
  parameter           PDX_SRX = 9; // power-down/self-refresh exit
  parameter           PDE     = 10;// power-down entry
  parameter           Rp      = 11; // read with auto precharge
  parameter           Wp      = 12; // write with auto precharge
  parameter           PA      = 13; // precharge all
  parameter           ZQCS    = 14; // ZQ Calibration (Short)
  parameter           ZQCL    = 15; // ZQ Calibration (Long)
  

  integer             cmd;
  integer             bank;
  real                rank;
  integer             row;
  integer             col;
  integer             seq_c;
  integer             fd;
  integer             col_cnt = 0;

  reg [nk_max-1:0]    prev_cke;
  
  wire [raw-1:0]      m_a_no10 = {m_a[raw-1:11], m_a[9:0]};

  always @(posedge clk) begin
    prev_cke <= m_cke;
    if( cmd === R || cmd === Rp || cmd === W || cmd === Wp ) col_cnt <= col_cnt+1;
  end

  // Given that all signals transition on the negedge except prev_cke, including prev_cke in 
  // the sensitivity list causes the PDE command to be decoded for half clock period only.
  // Another possible fix is to sample m_cke on the negedge.
  // This problem only exist when attaching the radix to a negative edge interface like the
  // PHY-Memory interface. If the radix is attached to the PCTL-PHY interface there is no problem.
  // Another possible fix is to sample m_cke on the negedge 
  always @(m_cke or prev_cke or m_cs_n or m_ras_n or m_cas_n or m_we_n or m_ba or m_a or m_a_no10) 
    begin: mem_bus_decode
      bank = 'dz;
      rank = 'dz;
      row = 'dz;
      col = 'dz;
      seq_c = 'dz;
      casez( {|prev_cke, |m_cke, &m_cs_n, m_ras_n, m_cas_n, m_we_n} )
        6'b111??? : cmd = 'dz;
        6'b110111 : cmd = 'dz;
        6'b110101 : begin
	        cmd   = m_a[10] ? Rp : R; 
	        bank  = m_ba; 
	        col   = m_a_no10[caw-1:0]; 
	        seq_c = col_cnt; 
	        case(~m_cs_n)
	          4'b0001 : rank = 0;
	          4'b0010 : rank = 1;
	          4'b0100 : rank = 2;
	          4'b1000 : rank = 3;
	          default : rank = -1;
	        endcase
        end
        6'b110100 : begin
	        cmd   = m_a[10] ? Wp : W; 
	        bank  = m_ba; 
	        col   = m_a_no10[caw-1:0]; 
	        seq_c = col_cnt; 
	        case(~m_cs_n)
	          4'b0001 : rank = 0;
	          4'b0010 : rank = 1;
	          4'b0100 : rank = 2;
	          4'b1000 : rank = 3;
	          default : rank = -1;
	        endcase
        end
        6'b110010 : begin
	        cmd  = m_a[10] ? PA : P; 
	        bank = m_ba; 
	        case(~m_cs_n)
	          4'b0001 : rank = 0;
	          4'b0010 : rank = 1;
	          4'b0100 : rank = 2;
	          4'b1000 : rank = 3;
	          default : rank = -1;
	        endcase
        end
        6'b110011 : begin
	        cmd  = A; bank = m_ba; 
	        row  = m_a; 
	        case(~m_cs_n)
	          4'b0001 : rank = 0;
	          4'b0010 : rank = 1;
	          4'b0100 : rank = 2;
	          4'b1000 : rank = 3;
	          default : rank = -1;
	        endcase
        end
        6'b110001 : cmd = REF;
        6'b110000 : cmd = MRS;
        6'b100001 : cmd = SRE;
        6'b110110 : cmd = m_a[10] ? ZQCL : ZQCS;
        6'b011??? : cmd = PDX_SRX;
        6'b010111 : cmd = PDX_SRX;
        6'b101??? : cmd = PDE;
        6'b100111 : cmd = PDE;
        default : cmd = 'dz;
      endcase
    end

endmodule
