/****************************************************************************************
*
* Name:  mobile_ddr3.v
*      Version:  0.16
*        Model:  BUS Functional
*
* Dependencies:  mobile_ddr3_parameters.vh
*
*  Description:  Micron MOBILE SDRAM DDR3 (Double Data Rate 3)
*
*   Limitation:  - doesn't check all refresh timings (tREFW, tREFI)
*                - positive ck and ck_n edges are used to form internal clock
*                - positive dqs and dqs_n edges are used to latch data
*                - mode registers settings are not checked for legal values
*                - PASR_Bank, PASR_Segment and Refresh Rate mode registers are not modeled
*                - setup and hold checking is not performed on command or data bus
*                - clock period is not checked
*                - write data strobes are not checked for correct timings
*                - DPD does not clear memory array when `MAX_MEM is defined
*
*         Note:  - Set simulator resolution to "ps" accuracy
*                - Set mcd_info = 0 to disable $display messages
*
*   Disclaimer   This software code and all associated documentation, comments or other 
*  of Warranty:  information (collectively "Software") is provided "AS IS" without 
*                warranty of any kind. MICRON TECHNOLOGY, INC. ("MTI") EXPRESSLY 
*                DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
*                TO, NONINFRINGEMENT OF THIRD PARTY RIGHTS, AND ANY IMPLIED WARRANTIES 
*                OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. MTI DOES NOT 
*                WARRANT THAT THE SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE 
*                OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. 
*                FURTHERMORE, MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR 
*                THE RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS, 
*                ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT OF USE 
*                OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO EVENT SHALL MTI, 
*                ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE LIABLE FOR ANY DIRECT, 
*                INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR SPECIAL DAMAGES (INCLUDING, 
*                WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, BUSINESS INTERRUPTION, 
*                OR LOSS OF INFORMATION) ARISING OUT OF YOUR USE OF OR INABILITY TO USE 
*                THE SOFTWARE, EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
*                DAMAGES. Because some jurisdictions prohibit the exclusion or 
*                limitation of liability for consequential or incidental damages, the 
*                above limitation may not apply to you.
*
*                Copyright 2003 Micron Technology, Inc. All rights reserved.
*
* Rev   Author   Date        Changes
* ---------------------------------------------------------------------------------------
* 0.00  MYY      04/20/11    Initial Release
* 0.10  MYY      04/01/12    Update to spec rev 0.8
* 0.12  MYY      02/12/13    match rl14/16 setting to JEDEC 
* 0.14  MYY      02/25/13    added nwr14/16 for MR2 and RZQ/4 for MR11
* 0.16  MYY      06/18/13    disable CA valid check when cs_n high
****************************************************************************************/

// DO NOT CHANGE THE TIMESCALE
// MAKE SURE YOUR SIMULATOR USES "PS" RESOLUTION
`timescale 1ps / 1ps

module mobile_ddr3 (
    ck,
    ck_n,
    cke,
    cs_n,
    ca,
    dm,
    dq,
    dqs,
    dqs_n,
    odt
);
    `include "mobile_ddr3_parameters.vh"

    `define DQ_PER_DQS DQ_BITS/DQS_BITS
    `define MAX_BITS   (BA_BITS+ROW_BITS+COL_BITS-1)
    `define MAX_PIPE   2*CL_MAX + BL_MAX
    `define MEM_SIZE   (1<<MEM_BITS)

    // ports
    input                       ck;
    input                       ck_n;
    input                       cke;
    input                       cs_n;
    input         [CA_BITS-1:0] ca;
    input         [DM_BITS-1:0] dm;
    inout         [DQ_BITS-1:0] dq;
    inout        [DQS_BITS-1:0] dqs;
    inout        [DQS_BITS-1:0] dqs_n;
    input                       odt;
                            
    // clock
    time                        tck_i;
    time                        tm_ck_pos;
    time                        tm_ck_hi;
    reg                         diff_ck;
    always @(posedge ck)        diff_ck <= ck;
    always @(posedge ck_n)      diff_ck <= ~ck_n;

    // cke, ca[0], ca[1], ca[2], ca[[3]
    // X means H or L (but a defined logic level)
    parameter
        MRW_CMD   = 5'b10000,
        MRR_CMD   = 5'b10001,
        REFPB_CMD = 5'b10010,
        REFAB_CMD = 5'b10011,
        ACT_CMD   = 5'b101xx,
        WRITE_CMD = 5'b1100x,
        READ_CMD  = 5'b1101x,
        BST_CMD   = 5'b11100,
        PRE_CMD   = 5'b11101,
        NOP_CMD   = 5'b1111x,
        SREF_CMD  = 5'b0001x,
        DPD_CMD   = 5'b0110x,
        PD_CMD    = 5'b0111x
    ;

   parameter MRRBIT = 1'b0;
 
    // command address
    reg                         cke_q;
    wire 			cke_in = cke;
    wire                  [4:0] cmd = {cke, ~cs_n ? {ca[0], ca[1], ca[2], ca[3]} : 4'b111x};  // deselect = nop 
    reg                   [3:0] cke_cmd;
    reg           [CA_BITS-1:0] ca_q;
    reg                         ab;
    reg                   [9:0] ma;
    reg                   [7:0] op;
    reg           [BA_BITS-1:0] ba;
    reg                  [14:0] r;
    reg                  [11:0] c;
    reg                   [1:0]	ecbbl;
   
    // cmd timers/counters
    integer                     ck_cntr;
    integer                     ck_cke;
    integer                     ck_mrw;
    integer                     ck_mrr;
    integer                     ck_ref;
    integer                     ck_act;
    integer                     ck_write;
    integer                     ck_write_end;
    integer                     ck_read;
    integer                     ck_read_end;
    integer                     ck_pre;
    integer                     ck_prea;
    integer                     ck_bst;
    integer                     ck_pd;
    integer                     ck_dpd;
    integer                     ck_sref;
    integer                     ck_bank_act [(1<<BA_BITS)-1:0];
    integer                     ck_bank_write [(1<<BA_BITS)-1:0];
    integer                     ck_bank_write_end [(1<<BA_BITS)-1:0];
    integer                     ck_bank_read [(1<<BA_BITS)-1:0];
    integer                     ck_bank_read_end [(1<<BA_BITS)-1:0];
    integer                     ck_bank_pre [(1<<BA_BITS)-1:0];
    integer                     ck_bank_ref [(1<<BA_BITS)-1:0];
    integer                     ck_ca_train0, ck_ca_train1, ck_ca_train2, ck_ca_train3;

    time                        tm_init3;
    time                        tm_init4;
    time                        tm_cke;
    time                        tm_ref;
    time                        tm_refa;
    time                        tm_act;
    time                        tm_write_end;
    time                        tm_read_end;
    time                        tm_pre;
    time                        tm_prea;
    time                        tm_bst;
    time                        tm_pd;
    time                        tm_dpd;
    time                        tm_sref;
    time                        tm_zq;
    time                        tm_bank_act [(1<<BA_BITS)-1:0];
    time                        tm_bank_write_end [(1<<BA_BITS)-1:0];
    time                        tm_bank_read_end [(1<<BA_BITS)-1:0];
    time                        tm_bank_pre [(1<<BA_BITS)-1:0];
    time                        tm_bank_ref [(1<<BA_BITS)-1:0];
    time                        tm_burst_refa [15:0];
    time                        tm_writelevel_start;

    // DRAM state
    reg                   [7:0] mr [255:0]; // mode register
    wire                 [19:0] mrwe = 20'b00110000111000001110; // mode registers: 1 = write only, 0 = read only or RFU , x = read/write
    reg                   [7:0] mrmask [255:0]; // mode register mask

    // MR1

    // wire                  [4:0] bl  = 1<<(mr[1] & 7); // range 4-16
    reg [5:0] 			bl;
    reg [5:0] 			lastrd_bl;
    reg [5:0] 			lastwr_bl;
    reg 			writeleveling;
				
    function [5:0] updatebl(input reg [1:0] ecbbl);
       updatebl = 2**(mr[1] & 4'h7);
    endfunction

    reg                   [2:0] init;
    reg           [BA_BITS-1:0] cas_ba;
    reg      [(1<<BA_BITS)-1:0] bank_ap;
    reg      [(1<<BA_BITS)-1:0] write_ap;
    reg      [(1<<BA_BITS)-1:0] read_ap;
    reg           [BA_BITS-1:0] bank_ref;
    reg                   [3:0] burst_refa;
    reg      [(1<<BA_BITS)-1:0] bank_active;
    reg          [ROW_BITS-1:0] row_active [(1<<BA_BITS)-1:0];
    reg                         neg_en, ca_neg_en;
    reg                [SX-1:0] partial_write;
    integer                     i;
    integer                     j;
 
    reg           [`MAX_PIPE:0] wr_pipeline;
    reg           [`MAX_PIPE:0] rd_pipeline;
    reg				rd_pipeline_prevbit0;
    reg           [BA_BITS-1:0] ba_pipeline [`MAX_PIPE:0];
    reg          [ROW_BITS-1:0] row_pipeline [`MAX_PIPE:0];
    reg          [COL_BITS-1:0] col_pipeline [`MAX_PIPE:0];
    reg                   [9:0] ma_pipeline [`MAX_PIPE:0];

    // rx
    wire                  [7:0] dm_in = dm;
    wire                 [63:0] dq_in = dq;
    wire                  [7:0] dqs_even = dqs;
    wire                  [7:0] dqs_odd = dqs_n;
    reg                   [7:0] dqs_even_prev = 'z;
    reg                   [7:0] dqs_odd_prev = 'z;
    reg                   [7:0] dm_in_pos;
    reg                   [7:0] dm_in_neg;
    reg                  [63:0] dq_in_pos;
    reg                  [63:0] dq_in_neg;

    // transmit
    reg                         dqs_out_en ;
    reg                         dqs_out;
    reg                         dq_out_en;
    reg          [DQ_BITS-1:0]  dq_out;

    bufif1 buf_dqs    [DQS_BITS-1:0] (dqs,    {DQS_BITS{dqs_out}}, dqs_out_en);
    bufif1 buf_dqs_n  [DQS_BITS-1:0] (dqs_n, {DQS_BITS{~dqs_out}}, dqs_out_en);
    bufif1 buf_dq      [DQ_BITS-1:0] (dq,                  dq_out,  dq_out_en);
   
    reg                         dqs_out_ca_en ;
    reg [DQS_BITS-1:0]          dqs_out_ca;
    reg [DQS_BITS-1:0]          dqs_out_ca_n;

    bufif1 buf_dqs_ca    [DQS_BITS-1:0] (dqs,    dqs_out_ca, dqs_out_ca_en);
    bufif1 buf_dqs_n_ca  [DQS_BITS-1:0] (dqs_n,  dqs_out_ca_n, dqs_out_ca_en);

    // IO
    reg         [8*MSGLENGTH:1] msg;
    integer                     warnings;
    integer                     errors;
    integer                     failures;
    integer                     mcd_info;
    integer                     mcd_warn;
    integer                     mcd_error;
    integer                     mcd_fail;

    // memory
    reg         [2*DQ_BITS-1:0] memory_data;
    reg         [2*DQ_BITS-1:0] bit_mask;
    reg           [DQ_BITS-1:0] dq_temp;
`ifdef MAX_MEM
    parameter RFF_BITS = DQ_BITS;
    // %z format uses 8 bytes for every 32 bits or less
    parameter RFF_CHUNK = 8 * ((RFF_BITS*2)/32 + ((RFF_BITS*2)%32 ? 1 : 0));
    reg [1024:1] tmp_model_dir;
    integer memfd [(1<<BA_BITS)-1:0];

    initial
    begin : file_io_open
        integer bank;

        if (!$value$plusargs("model_data+%s", tmp_model_dir))
        begin
            tmp_model_dir = "/tmp";
            $display(
                "%m: at time %t WARNING: no +model_data option specified, using /tmp.",
                $time
            );
        end

        for (bank = 0; bank < (1<<BA_BITS); bank = bank + 1)
            memfd[bank] = open_bank_file(bank);
    end
`else
    reg         [2*DQ_BITS-1:0] memory  [0:`MEM_SIZE-1];
    reg         [`MAX_BITS-1:0] address [0:`MEM_SIZE-1];
    reg            [MEM_BITS:0] memory_index;
    reg            [MEM_BITS:0] memory_used;
`endif

    reg [3:0] 				nwr;
    always @(mr[1]) begin
       if (mr[2]&8'h10)
	 case (mr[1]>>5)
	   3'b000: nwr=10;
	   3'b001: nwr=11;
	   3'b010: nwr=12;
	   3'b100: nwr=14;
	   3'b110: nwr=16;
	   default: nwr='x;
	 endcase
       else
	 case (mr[1]>>5)
	   3'b001: nwr=3;
	   3'b100: nwr=6;
	   3'b110: nwr=8;
	   3'b111: nwr=9;
	   default: nwr='x;
	 endcase
    end
   
    // MR2
    reg [4:0] rl;
    reg [3:0] wl;
    always @(mr[2]) begin
       case (mr[2]&4'hf)
	 4'b0001: begin rl=3; wl=1; end
	 4'b0010: begin rl=4; wl=2; end
	 4'b0011: begin rl=5; wl=2; end
	 4'b0100: begin rl=6; wl=3; end
	 4'b0101: begin rl=7; wl=4; end
	 4'b0110: begin rl=8; wl=4; end
	 4'b0111: begin rl=9; wl=5; end
	 4'b1000: begin rl=10; wl=6; end
	 4'b1001: begin rl=11; wl=6; end
	 4'b1010: begin rl=12; wl=6; end
	 4'b1100: begin rl=14; wl=8; end
	 4'b1110: begin rl=16; wl=8; end
	 default: begin rl='x; wl='x; end
       endcase
`ifdef lpddr3_wlsetb
       if (mr[2]&8'h40) // WLSETB set
	 case (mr[2]&4'hf)
	   4'b1000: wl=8;
	   4'b1001: wl=9; 
	   4'b1010: wl=9; 
	 endcase
`endif
       if (mr[2]&8'h10)
	 case (mr[1]>>5)
	   3'b000: nwr=10;
	   3'b001: nwr=11;
	   3'b010: nwr=12;
	   3'b100: nwr=14;
	   3'b110: nwr=16;
	   default: nwr='x;
	 endcase
       else
	 case (mr[1]>>5)
	   3'b001: nwr=3;
	   3'b100: nwr=6;
	   3'b110: nwr=8;
	   3'b111: nwr=9;
	   default: nwr='x;
	 endcase
       writeleveling = mr[2]>>7;
       if (writeleveling) begin
	  tm_writelevel_start = $time;
	  dq_out_en <= #(TDQSCK+20) 1'b1;
	  dq_out <= #(TDQSCK+20) {DQ_BITS{1'b0}};

       end else
	 dq_out_en <= #(TDQSCK+20) 1'b0;
	 
    end

    // MR10
    wire                  [7:0] calibration_code = mr[10];
    parameter                   
        CAL_INIT  = 8'hFF,
        CAL_LONG  = 8'hAB,
        CAL_SHORT = 8'h56,
        CAL_ZQ    = 8'hC3
    ;

    // MR11
    wire [2:0] rtt_mode_reg = mr[11];
    reg        odt_pincontrol;
    int        odt_pincontrol_semaphore = 0;
    reg        odt_rd_dis;

    always @(rtt_mode_reg) begin
       odt_pincontrol <= 1'bx;
       odt_pincontrol <= #(MRW*tck_i+tck_i*2) 1'b1;
    end
   
    always @(odt_rd_dis) 
      if (odt_pincontrol !== ~odt_rd_dis) begin
	 odt_pincontrol <= 1'bx;
	 odt_pincontrol <= #(600ps) ~odt_rd_dis;
      end
   
    always @(posedge cke_in) 
      if (rtt_mode_reg[1:0]) begin
	 odt_pincontrol <= 1'bx;
      end
   
    // pull dq pins high when rtt is on
    reg [15:0] rtt_val;
    wire rtt_valid = (rtt_val!==16'bx);
    wire  rtt_dq_pull = (rtt_val===240 || rtt_val===120);
    assign (weak0, weak1) dq    = rtt_dq_pull ? {DQ_BITS{1'b1}}:{DQ_BITS{1'bz}};
    assign (weak0, weak1) dm    = rtt_dq_pull ? {DM_BITS{1'b1}}:{DM_BITS{1'bz}};
    assign (weak0, weak1) dqs   = rtt_dq_pull ? {DQS_BITS{1'b1}}:{DQS_BITS{1'bz}};
    assign (weak0, weak1) dqs_n = rtt_dq_pull ? {DQS_BITS{1'b1}}:{DQS_BITS{1'bz}};

    reg [15:0] rtt_sync_val;
   
    // MR16
    wire                  [1:0] pasr = mr[16]; // S2
    wire                  [7:0] pasr_bank = mr[16]; // S4
    // MR17
    wire                  [7:0] pasr_segment = mr[17]; // 1Gb-8Gb S4

    // CA Training MR41 MR42 MR48
    reg                   [2:0] ca_train;
    always @(mr[41])
      if (mr[41] == 8'ha4) begin
	 mr[41] = 'x;
	 ca_train=1;
	 ck_ca_train0 = ck_cntr-1;
      end
   
    always @(mr[48])
      if (mr[48] == 8'hc0) begin
	 mr[48] = 'x;
	 ca_train=2;
	 ck_ca_train0 = ck_cntr-1;
      end
   
   always @(mr[42])
     if (mr[42] == 8'ha8) begin
	mr[42] = 'x;
	ca_train <= #TMRZ 0;
	dq_out_en <= #TMRZ 1'b0;
	dqs_out_ca_en <= #TMRZ 1'b0;
     end

    // initial state
    initial begin
        cke_q = 0;
        ck_cntr = 2;
        ck_cke = 0;
        ck_write = 0;
        ck_read = 0;
        ck_bst = 0;
        tm_cke = 0;
        init = 1;
        ca_train = 0;
        burst_refa = 0;
        neg_en = 0;
        ca_neg_en = 0;
        wr_pipeline = 0;
        rd_pipeline = 0;
        rd_pipeline_prevbit0 = 0;
        dqs_out_en = 0;
        dqs_out_ca_en = 0;
        dq_out_en = 0;
        cas_ba = 0;

        bank_ap <= 0;
        write_ap <= 0;
        read_ap <= 0;
        bank_active <= 0;
        bank_ref <= 0;
       
        warnings = 0;
        errors = 0;
        failures = 0;
        mcd_info = 0;
        mcd_warn = 0;
        mcd_error = 1;
        mcd_fail = 1;

        rtt_val = 16'bz;
        rtt_sync_val = 16'bz;
        odt_pincontrol = 0;
        odt_rd_dis = 0;
       
        // define which bits are RFU in the W and RW mode registers
        mrmask[1]  <= 8'hFF;
        mrmask[2]  <= 8'hFF;
        mrmask[3]  <= 8'hFF;
        mrmask[9]  <= 8'hFF;
        mrmask[10] <= 8'hFF;
        mrmask[11] <= 8'h07;
        mrmask[16] <= 8'hFF;
        mrmask[17] <= 8'hFF;
        mrmask[41] <= 8'hFF;
        mrmask[42] <= 8'hFF;
        mrmask[48] <= 8'hFF;

        // all RFU MRR should read out zero
        for(i=0; i<=255; i=i+1) 
	    mr[i] = 8'h00;
    end

    task chk_err;
        input [4:0] fromcmd;
        input [4:0] cmd;
    begin
        casex ({fromcmd, cmd})
            // The Mode Register Write Command period is tMRW. No command (other than Nop or Deselect) is allowed during this period.
            {MRW_CMD  , MRW_CMD  } ,
            {MRW_CMD  , MRR_CMD  } ,
            {MRW_CMD  , REFPB_CMD} ,
            {MRW_CMD  , REFAB_CMD} ,
            {MRW_CMD  , ACT_CMD  } ,
          //{MRW_CMD  , WRITE_CMD} ,
          //{MRW_CMD  , READ_CMD } ,
          //{MRW_CMD  , BST_CMD  } ,
          //{MRW_CMD  , PRE_CMD  } ,
            {MRW_CMD  , PD_CMD   } ,
            {MRW_CMD  , DPD_CMD  } ,      
            {MRW_CMD  , SREF_CMD } : begin if (ck_cntr - ck_mrw < MRW) ERROR ("tMRW violation"); end

            // The Mode Register Command period is tMRR. No command (other than Nop or Deselect) is allowed during this period.
            // Deep power down, power down and self refresh can not be entered while read or write, mode register read, mode register write, or precharge operations are in progress.
            {MRR_CMD  , MRW_CMD  } ,
            {MRR_CMD  , MRR_CMD  } ,
            {MRR_CMD  , REFPB_CMD} ,
            {MRR_CMD  , REFAB_CMD} ,
            {MRR_CMD  , ACT_CMD  } ,
            {MRR_CMD  , WRITE_CMD} ,
            {MRR_CMD  , READ_CMD } ,
            {MRR_CMD  , BST_CMD  } ,
            {MRR_CMD  , PRE_CMD  } : begin if (ck_cntr - ck_mrr < MRR) ERROR ("tMRR violation"); end
            {MRR_CMD  , PD_CMD   } , // CKE may be registered LOW RL + RU(tDQSCK/tCK)+ BL/2 + 1 clock cycles after the clock on which the Mode Register Read command is registered.
            {MRR_CMD  , DPD_CMD  } , 
            {MRR_CMD  , SREF_CMD } : begin if (ck_cntr - ck_mrr < rl + ceil(1.0*TDQSCK_MAX/tck_i) + 2 + 1) ERROR ("MRR to CKE low violation"); end

            {REFPB_CMD, MRW_CMD  } ,
            {REFPB_CMD, MRR_CMD  } ,
            {REFPB_CMD, REFPB_CMD} ,
            {REFPB_CMD, REFAB_CMD} ,
          //{REFPB_CMD, WRITE_CMD} ,
          //{REFPB_CMD, READ_CMD } ,
          //{REFPB_CMD, BST_CMD  } ,
          //{REFPB_CMD, PRE_CMD  } ,
          //{REFPB_CMD, PD_CMD   } , legal
          //{REFPB_CMD, DPD_CMD  } , legal 
            {REFPB_CMD, SREF_CMD } : begin if ($time - tm_ref < TRFCPB) ERROR ("tRFCpb violation"); end
            {REFPB_CMD, ACT_CMD  } : begin if ($time - tm_bank_ref[ba] < TRFCPB) ERROR ("tRFCpb violation"); if ((ck_cntr - ck_ref < RRD) || ($time - tm_ref < TRRD)) ERROR ("tRRD violation"); end
  
            {REFAB_CMD, MRW_CMD  } ,
            {REFAB_CMD, MRR_CMD  } ,
            {REFAB_CMD, REFPB_CMD} ,
            {REFAB_CMD, REFAB_CMD} ,
            {REFAB_CMD, ACT_CMD  } ,
          //{REFAB_CMD, WRITE_CMD} ,
          //{REFAB_CMD, READ_CMD } ,
          //{REFAB_CMD, BST_CMD  } ,
          //{REFAB_CMD, PRE_CMD  } ,
          //{REFAB_CMD, PD_CMD   } , legal
          //{REFAB_CMD, DPD_CMD  } , legal 
            {REFAB_CMD, SREF_CMD } : begin if ($time - tm_refa < TRFCAB) ERROR ("tRFCab violation"); end

          //{ACT_CMD  , MRW_CMD  } ,
          //{ACT_CMD  , MRR_CMD  } ,
            {ACT_CMD  , REFPB_CMD} ,
          //{ACT_CMD  , REFAB_CMD} ,
            {ACT_CMD  , ACT_CMD  } : begin if ((ck_cntr - ck_act < RRD) || ($time - tm_act < TRRD)) ERROR ("tRRD violation"); end
            {ACT_CMD  , WRITE_CMD} ,
            {ACT_CMD  , READ_CMD } : begin if ((ck_cntr - ck_bank_act[ba] < RCD) || ($time - tm_bank_act[ba] < TRCD)) ERROR ("tRCD violation"); end
          //{ACT_CMD  , BST_CMD  } ,
            {ACT_CMD  , PRE_CMD  } : begin if ((ab && ((ck_cntr - ck_act < RAS) || ($time - tm_act < TRAS))) || (!ab && ((ck_cntr - ck_bank_act[ba] < RAS) || ($time - tm_bank_act[ba] < TRAS)))) ERROR ("tRAS violation"); end
          //{ACT_CMD  , PD_CMD   } , legal
          //{ACT_CMD  , DPD_CMD  } , legal 
          //{ACT_CMD  , SREF_CMD } , 

          //{WRITE_CMD, REFPB_CMD} ,
          //{WRITE_CMD, REFAB_CMD} ,
          //{WRITE_CMD, ACT_CMD  } ,
            {WRITE_CMD, WRITE_CMD} : begin if (ck_cntr - ck_write < SX/2) ERROR ("tCCD violation"); end
          //{WRITE_CMD, BST_CMD  } ,
            {WRITE_CMD, PRE_CMD  } : begin if ((ab && ((ck_cntr - ck_write_end < WR) || ($time - tm_write_end < TWR))) 
                                            || (!ab && ((ck_cntr - ck_bank_write_end[ba] < WR) || ($time - tm_bank_write_end[ba] < TWR)))) 
                                                ERROR ("tWR violation"); end
            {WRITE_CMD, MRR_CMD  } , // The minimum number of clock cycles from the burst write command to the Mode Register Read command is [WL + 1 + BL/2 + RU( tWTR/tCK)].
            {WRITE_CMD, MRW_CMD  } , // The minimum number of clock cycles from the burst write command to the Mode Register Write command is [WL + 1 + BL/2 + RU( tWTR/tCK)].
            {WRITE_CMD, READ_CMD } : begin if ((ck_cntr - ck_write_end < WTR) || ($time - tm_write_end < TWTR)) ERROR ("tWTR violation"); end
            {WRITE_CMD, PD_CMD   } , // CKE may be registered LOW WL + 1 + BL/2 + RU(tWR/tCK) + 1 clock cycles after the Write command is registered.
            {WRITE_CMD, DPD_CMD  } , 
            {WRITE_CMD, SREF_CMD } : begin if ((ck_cntr - ck_write_end < WR + 1) || ($time - tm_write_end < TWR)) ERROR ("Write to Power Down violation"); end

            {READ_CMD , MRW_CMD  } : // The minimum number of clock cycles from the burst read command to the Mode Register Write command is [RL + RU( tDQSCK/tCK) + BL/2].
                                     begin if (ck_cntr - ck_read_end < rl + ceil(1.0*TDQSCK_MAX/tck_i) + SX/2) ERROR ("Read to MRW violation"); end
            {READ_CMD , MRR_CMD  } : // The minimum number of clocks from the burst read command to the Mode Register Read command is BL/2.
                                     begin if (ck_cntr - ck_read_end < SX/2) ERROR ("Read to MRR violation"); end
          //{READ_CMD , REFPB_CMD} ,
          //{READ_CMD , REFAB_CMD} ,
          //{READ_CMD , ACT_CMD  } , 
            {READ_CMD , WRITE_CMD} : // Minimum read to write latency is RL + RU(tDQSCKmax/tCK) + BL/2 + 1 - WL clock cycles.
                                     begin if (ck_cntr - ck_read_end < rl + ceil(1.0*TDQSCK_MAX/tck_i) + SX/2 + 1 - wl) ERROR ("tRTW violation"); end
            {READ_CMD , READ_CMD } : begin if (ck_cntr - ck_read < SX/2) ERROR ("tCCD violation"); end
          //{READ_CMD , BST_CMD  } ,
            {READ_CMD , PRE_CMD  } : begin if ((ab && ((ck_cntr - ck_read_end < RTP) || ($time - tm_read_end < TRTP))) || (!ab && ((ck_cntr - ck_bank_read_end[ba] < RTP) || ($time - tm_bank_read_end[ba] < TRTP)))) ERROR ("tRTP violation"); end
            {READ_CMD , PD_CMD   } , // CKE may be registered LOW RL + RU(tDQSCK/tCK)+ BL/2 + 1 clock cycles after the clock on which the Read command is registered.
            {READ_CMD , DPD_CMD  } ,
            {READ_CMD , SREF_CMD } : begin if (ck_cntr - ck_read_end < rl + ceil(1.0*TDQSCK_MAX/tck_i) + SX/2 + 1) ERROR ("Read to Power Down violation"); end

          //{BST_CMD  , MRW_CMD  } ,
          //{BST_CMD  , MRR_CMD  } ,
          //{BST_CMD  , REFPB_CMD} ,
          //{BST_CMD  , REFAB_CMD} ,
          //{BST_CMD  , ACT_CMD  } ,
          //{BST_CMD  , WRITE_CMD} ,
          //{BST_CMD  , READ_CMD } ,
          //{BST_CMD  , BST_CMD  } ,
          //{BST_CMD  , PRE_CMD  } ,
          //{BST_CMD  , PD_CMD   } ,
          //{BST_CMD  , DPD_CMD  } ,
          //{BST_CMD  , SREF_CMD } ,

            {PRE_CMD  , MRR_CMD  } : begin if ((ck_cntr - ck_prea < RPAB) || ($time - tm_prea < TRPAB)) ERROR ("tRPab violation"); end
            {PRE_CMD  , MRW_CMD  } ,
            {PRE_CMD  , REFAB_CMD} ,
            {PRE_CMD  , SREF_CMD } : begin if ((ck_cntr - ck_pre < RPPB) || ($time - tm_pre < TRPPB)) ERROR ("tRPpb violation");
                                           if ((ck_cntr - ck_prea < RPAB) || ($time - tm_prea < TRPAB)) ERROR ("tRPab violation"); end
	  // for REFPB, use bank_ref instead
	    {PRE_CMD  , REFPB_CMD} : begin if ((ck_cntr - ck_bank_pre[bank_ref] < RPPB) || ($time - tm_bank_pre[bank_ref] < TRPPB)) ERROR ("tRPpb violation");
                                           if ((ck_cntr - ck_prea < RPAB) || ($time - tm_prea < TRPAB)) ERROR ("tRPab violation"); end
	      
            {PRE_CMD  , ACT_CMD  } : begin if ((ck_cntr - ck_bank_pre[ba] < RPPB) || ($time - tm_bank_pre[ba] < TRPPB)) ERROR ("tRPpb violation");
                                           if ((ck_cntr - ck_prea < RPAB) || ($time - tm_prea < TRPAB)) ERROR ("tRPab violation"); end
          //{PRE_CMD  , WRITE_CMD} ,
          //{PRE_CMD  , READ_CMD } ,
          //{PRE_CMD  , BST_CMD  } ,
          //{PRE_CMD  , PRE_CMD  } , legal
          //{PRE_CMD  , PD_CMD   } , legal
          //{PRE_CMD  , DPD_CMD  } , legal

                                           
            {SREF_CMD , MRW_CMD  } ,
            {SREF_CMD , MRR_CMD  } ,
            {SREF_CMD , REFPB_CMD} ,
            {SREF_CMD , REFAB_CMD} ,
            {SREF_CMD , ACT_CMD  } : begin if ((ck_cntr - ck_sref < XSR) || ($time - tm_sref < TXSR)) ERROR ("tXSR violation"); end
          //{SREF_CMD , WRITE_CMD} ,
          //{SREF_CMD , READ_CMD } ,
          //{SREF_CMD , BST_CMD  } ,
          //{SREF_CMD , PRE_CMD  } ,
            {SREF_CMD , PD_CMD   } ,
            {SREF_CMD , DPD_CMD  } ,
            {SREF_CMD , SREF_CMD } : begin if (ck_cntr - ck_sref < CKE) ERROR ("tCKE violation"); end

          //{DPD_CMD  , MRW_CMD  } ,
          //{DPD_CMD  , MRR_CMD  } ,
          //{DPD_CMD  , REFPB_CMD} ,
          //{DPD_CMD  , REFAB_CMD} ,
          //{DPD_CMD  , ACT_CMD  } ,
          //{DPD_CMD  , WRITE_CMD} ,
          //{DPD_CMD  , READ_CMD } ,
          //{DPD_CMD  , BST_CMD  } ,
          //{DPD_CMD  , PRE_CMD  } ,
            {DPD_CMD  , PD_CMD   } ,
            {DPD_CMD  , DPD_CMD  } ,
            {DPD_CMD  , SREF_CMD } : begin if (ck_cntr - ck_pd < CKE) ERROR ("tCKE violation"); end

            {PD_CMD   , MRR_CMD  } : begin if ((ck_cntr - ck_pd < XP+RCD) || ($time - tm_pd < TXP+TRCD)) ERROR ("tXP+tMRRI violation"); end
            {PD_CMD   , MRW_CMD  } ,
            {PD_CMD   , REFPB_CMD} ,
            {PD_CMD   , REFAB_CMD} ,
            {PD_CMD   , ACT_CMD  } : begin if ((ck_cntr - ck_pd < XP) || ($time - tm_pd < TXP)) ERROR ("tXP violation"); end
          //{PD_CMD   , WRITE_CMD} ,
          //{PD_CMD   , READ_CMD } ,
          //{PD_CMD   , BST_CMD  } ,
          //{PD_CMD   , PRE_CMD  } ,
            {PD_CMD   , PD_CMD   } ,
            {PD_CMD   , DPD_CMD  } ,
            {PD_CMD   , SREF_CMD } : begin if (ck_cntr - ck_pd < CKE) ERROR ("tCKE violation"); end
        endcase
    end
    endtask


    always @(diff_ck) begin

        // In power-down mode, CKE must be maintained LOW while all other input signals are "Don�t Care".
        // Once the LPDDR3 SDRAM has entered Self Refresh mode, all of the external signals except CKE, are "don�t care".
        // Deep Power-Down mode, all input buffers except CKE, all output buffers, and the power supply to internal circuitry may be disabled
        if ((init != 1) && (cke === 1'bx))
            ERROR ("cke must be driven to a defined logic level");
        if (cke_q && ~cs_n && ((&ca === 1'bx) || (|ca === 1'bx)))
            ERROR ("ca must be driven to a defined logic level while cke/cs_n is active");
        if (cke_q && (diff_ck === 1'bx))
            ERROR ("ck and ck_n must be driven to a defined logic level while cke is active");

        // determine if write mask is being used
        if (diff_ck) begin
            partial_write = (partial_write<<1) | &dm_in_neg[DM_BITS-1:0];
        end else begin
            partial_write = (partial_write<<1) | &dm_in_pos[DM_BITS-1:0];
        end

        if (diff_ck) begin
            // initialization
            case (init)
                1 : begin // 1. Power Ramp
                    // CKE low required during tINIT1 and tINIT2
                    if (cke_in) begin
                        // DPD does not require tINIT1
                        if ((cke_cmd != DPD_CMD>>1) && ($time - tm_cke < TINIT1)) begin
                            ERROR ("tINIT1 violation");
                        end 
                        if (ck_cntr - ck_cke < INIT2) begin
                            ERROR ("tINIT2 violation");
                        end
                        // CKE high moves to tINIT3
                        init = 3;
                        tm_init3 <= $time;
                    end
                end
                3 : begin // 2. Reset command
                    // NOP allowed during tINIT3
                    if ((cmd[4:1] !== 4'b1111) && ($time - tm_init3 < TINIT3)) begin
                        ERROR ("tINIT3 violation");
                    end
                    // reset moves to tINIT4
                    if ((cmd == MRW_CMD) && (ca[9:4] == 'h3F)) begin
                        init = 4;
                        tm_init4 <= $time;
                    end

                end
                4 : begin
                    // NOP required during tINIT4
                    if ((cmd[4:1] !== 4'b1111) && ($time - tm_init4 < TINIT4)) begin
                        ERROR ("tINIT4 violation");
                    end
                    // CMD or tINIT4 moves to tINIT5
                    if ((cmd[4:1] !== 4'b1111) || ($time - tm_init4 >= TINIT4)) begin
                        init = 5;
                    end
                end
                5 : begin // 3. Mode Registers Reads and Device Auto-Initialization (DAI) polling:
                    // PD and MRR allowed during tINIT5
                    if ((cmd[3:1] !== 3'b111) && (cmd !== MRR_CMD) && ($time - tm_init4 < TINIT5)) begin
                        ERROR ("tINIT5 violation");
                    end
                    // CMD or tINIT5 finishes
                    if (((cmd[3:1] !== 3'b111) && (cmd !== MRR_CMD)) || ($time - tm_init4 >= TINIT5)) begin
                        init = 6;
                       mr[0] = {3'b000, MRRBIT, MRRBIT, 2'b00, MRRBIT};  // 0x00 Device info  // DAI complete
`ifdef lpddr3_wlsetb
                       mr[0][6] = 1'b1; 
`endif
`ifdef lpddr3_rl3
                       mr[0][7] = 1'b1; 
`endif
                    end
                end
                6 : begin // 4. ZQ Calibration
`ifdef REQUIRE_ZQINIT
                    if (calibration_code == CAL_INIT) begin
                        init = 7;
                    end
`else
		   init = 7;
`endif
                end
                7 : begin
                    // CMD or tZQINIT finishes
                    if ((cmd[3:1] !== 3'b111) || ($time - tm_zq >= TZQINIT)) begin
                        INFO ("Initialization complete");
                        init = 0; // done
                        mr[0] = {3'b000, MRRBIT, MRRBIT, 2'b00, MRRBIT};  // 0x00 Device info 
`ifdef lpddr3_wlsetb
                        mr[0][6] = 1'b1; 
`endif
`ifdef lpddr3_rl3
                        mr[0][7] = 1'b1; 
`endif
                    end
                end
            endcase

	    // CA training
	    case (ca_train)
	      1,2: begin // MODE 41
		 // NOP allowed during tCACKEL
                 if ((cs_n !== 1'b1 || cke_in !== 1'b1) && (ck_cntr - ck_ca_train0 < TCACKEL)) begin
                    ERROR ("tCACKEL violation");
                 end
		 // PDE moves to TCAENT
		 if (cke_in === 1'b0) begin
		    ck_ca_train1 = ck_cntr;
		    ck_ca_train2 = 2;
		    ca_train = ca_train+2;
		 end
	      end
	      3,4: begin // CKE LOW
		 // NOP allowed during tCAENT/tCAMRD
                 if ((cs_n !== 1'b1) && (ck_cntr - ck_ca_train1 < TCAENT)) begin
                    ERROR ("tCAENT violation");
                 end
                 if ((cs_n !== 1'b1) && (ck_cntr - ck_ca_train0 < TCAMRD)) begin
                    ERROR ("tCAMRD violation");
                 end
		 // CA Train cmd
		 if (cs_n === 1'b0) begin
		    // tCACD check
		    if (ck_cntr - ck_ca_train2 < (1.0*TADR+2.0*tck_i+0.99*tck_i)/tck_i) begin
                       ERROR ("tCCACD violation");
		    end
		    ck_ca_train2 = ck_cntr;
                    ca_neg_en <= 1'b1;  // output data on negedge
		 end
		 // PDX moves to tCAEXT
		 if (cke_in === 1'b1) begin
		    // tCACKEH check
		    if (ck_cntr - ck_ca_train2 < (1.0*TADR+1.0*tm_ck_hi+1.0*TCACKEH*tck_i+0.99*tck_i)/tck_i) begin
                       ERROR ("tCACKEH violation");
		    end
		    ck_ca_train3 = ck_cntr;
		    ca_train = 5;
		 end
	      end
	      5: begin // CKE HIGH
                 if ((cs_n !== 1'b1 || cke_in !== 1'b1) && (ck_cntr - ck_ca_train3 < TCAEXT)) begin
                    ERROR ("tCAEXT violation");
                 end
	      end
	    endcase

            // auto precharge
            if (|bank_ap) begin
                for (i=0; i<(1<<BA_BITS); i=i+1) begin
                    if (write_ap[i] && ((ck_cntr - ck_bank_write_end[i] >= nwr)
                        && (ck_cntr - ck_bank_act[i] >= RAS) && ($time - tm_bank_act[i] >= TRAS))) begin
                        // tWR violation if nwr < tWR
                        ba = i;
                        ab = 0;
                        chk_err(WRITE_CMD, PRE_CMD);
                        write_ap[i] = 1'b0;
                    end
                    if (read_ap[i] && ((ck_cntr - ck_bank_read_end[i] >= RTP) && ($time - tm_bank_read_end[i] >= TRTP)
                        && (ck_cntr - ck_bank_act[i] >= RAS) && ($time - tm_bank_act[i] >= TRAS))) begin
                        read_ap[i] = 1'b0;
                    end
                    if (bank_ap[i] && !write_ap[i] && !read_ap[i]) begin
                        $sformat (msg, "Auto Precharge bank %1d", i);
                        INFO (msg);
                        bank_ap[i] = 1'b0;
                        bank_active[i] = 1'b0;
                        ck_pre <= ck_cntr;
                        tm_pre <= $time;
                        ck_bank_pre[i] <= ck_cntr;
                        tm_bank_pre[i] <= $time;
                    end
                end
            end

            // shift pipelines
            if (|wr_pipeline || |rd_pipeline) begin
                wr_pipeline <= wr_pipeline>>1;
                rd_pipeline <= rd_pipeline>>1;
                for (i=0; i<`MAX_PIPE; i=i+1) begin
                    ba_pipeline[i]  <= ba_pipeline[i + 1];
                    row_pipeline[i] <= row_pipeline[i + 1];
                    col_pipeline[i] <= col_pipeline[i + 1];
                    ma_pipeline[i] <= ma_pipeline[i + 1];
                end
            end

            // *_read_end is start time for measuring tRTP
            if ((ck_read > ck_bst) && ((ck_cntr - ck_read)%(SX/2) == 0) && (ck_cntr - ck_bank_read[cas_ba] <= (lastrd_bl - SX)/2) && (cmd != READ_CMD) && (cmd != BST_CMD)) begin
                ck_read_end = ck_cntr;
                tm_read_end = $time;
                ck_bank_read_end[cas_ba] = ck_cntr;
                tm_bank_read_end[cas_ba] = $time;
            end

            // *_write_end is the start time for measuring tWR and tWTR
            if ((ck_cntr - ck_write)%(SX/2) == 0) begin
                for (i=0; i<(1<<BA_BITS); i=i+1) begin
                    if ((ck_cntr - ck_bank_write[i] <= wl + 1 + SX/2) || ((&partial_write == 0) && wr_pipeline[0] && (ba_pipeline[0] == i))) begin
                        ck_write_end = ck_cntr;
                        tm_write_end = $time;
                        ck_bank_write_end[i] = ck_cntr;
                        tm_bank_write_end[i] = $time;
                    end
                end
            end

            // TODO: The achieveable time without REFRESH commands is given by tREFW - (R / 8) * tREFBW = tREFW - R * 4 * tRFCab.

            // check timing
            ba = ca[9:7];
            ab = ca[4];
	    casex (cmd)
	    NOP_CMD: begin end
            default: begin
                chk_err(MRW_CMD  , cmd);
                chk_err(MRR_CMD  , cmd);
                chk_err(REFPB_CMD, cmd);
                chk_err(REFAB_CMD, cmd);
                chk_err(ACT_CMD  , cmd);
                chk_err(WRITE_CMD, cmd);
                chk_err(READ_CMD , cmd);
                chk_err(BST_CMD  , cmd);
                chk_err(PRE_CMD  , cmd);
                chk_err(SREF_CMD , cmd);
                chk_err(DPD_CMD  , cmd);
                chk_err(PD_CMD   , cmd);
                // ZQ Calibration
                case (calibration_code)
                    CAL_INIT  : begin if ($time - tm_zq < TZQINIT) ERROR ("tZQINIT violation"); end
                    CAL_LONG  : begin if ($time - tm_zq < TZQCL) ERROR ("tZQCL violation"); end
                    CAL_SHORT : begin if ($time - tm_zq < TZQCS) ERROR ("tZQCS violation"); end
                    CAL_ZQ    : begin if ($time - tm_zq < TZQRESET) ERROR ("TZQRESET violation"); end
                endcase
	        end
	    endcase

            // command decode
            casex ({cke_q, cmd})
                {1'b1, MRW_CMD} : begin
                    if (|bank_active && ca[9:4] != 'h3F) begin // reset for DPDE
                        ERROR ("All banks must be Precharged prior to MRW");
                    end else begin
                        if (ca[9:4] == 'h3F) begin
                            INFO ("Reset");
`ifdef MAX_MEM
                            erase_banks({(1<<BA_BITS){1'b1}});
`else
                            memory_used <= 0;
`endif
                            bank_ap <= 0;
                            write_ap <= 0;
                            read_ap <= 0;
                            bank_active <= 0;
                            bank_ref <= 0;

                            mr[0] = {3'b000, MRRBIT, MRRBIT, 2'b00, MRRBIT};  // 0x00 Device info 
`ifdef lpddr3_wlsetb
                            mr[0][6] = 1'b1; 
`endif
`ifdef lpddr3_rl3
                            mr[0][7] = 1'b1; 
`endif

`ifdef V80M
                            mr[1] <= 8'h03;   // 1 0x01 Device feature W nWR (for AP) BL
`else
                            mr[1] <= 8'h03;   // 1 0x01 Device feature W nWR (for AP) BL
`endif
                            mr[2] <= 8'h18;   // 2 0x02 Device feature W RFU RL & WL
                            mr[3] <= 8'hxx;   // 8'h02 I/O Config W Slew Rate Drive Strength
			    mr[4] <= 8'hxx;   // 8'h03 ignore refresh
                            mr[5] <= 8'hff;   // 0x05 Basic Config 1 R Name of Company
`ifdef HALF_DENSITY
                            mr[6] <= 8'h80;   // 0x06 Basic Config 2 R Revision ID1
`else
                            mr[6] <= 8'h00;   // 0x06 Basic Config 2 R Revision ID1
`endif
                            mr[7] <= 8'h00;   // 0x07 Basic Config 3 R Revision ID2
			    // mr[8] <= 0x08 Basic Config 4 R IO Width Density Type
`ifdef  lpddr3_4Gb
                            mr[8] <= ((DQ_BITS == 16)<<6) | (6<<2)  | MR8RESID;
`elsif  lpddr3_8Gb
                            mr[8] <= ((DQ_BITS == 16)<<6) | (7<<2)  | MR8RESID;
`elsif  lpddr3_16Gb
                            mr[8] <= ((DQ_BITS == 16)<<6) | (8<<2)  | MR8RESID;
`elsif  lpddr3_32Gb
                            mr[8] <= ((DQ_BITS == 16)<<6) | (9<<2)  | MR8RESID;
`endif						   
			    mr[11] <= 8'h00;
                            // 9 0x09 Test Mode W Vendor-specific
                            mr[16] <= 8'hxx; // 16 0x10 PASR bank
                            mr[17] <= 8'hx; // 17 0x11 PASR segment

                            // If the RESET command is issued outside the power up initialization sequence, 
                            // the reinitialization procedure shall begin with step 3.
                            if (init == 0) begin
                                init = 5;
                            end
                        end else begin
                            neg_en <= 1'b1;
                        end
                        ck_mrw <= ck_cntr;
                    end 
                end
                {1'b1, MRR_CMD} : begin
                    neg_en <= 1'b1;
                    ck_mrr <= ck_cntr;
                end
                {1'b1, REFPB_CMD} : begin
                    if (|init) begin
                        ERROR ("Initialization sequence must be complete prior to REFpb");
                    end else if (BA_BITS != 3) begin
                        ERROR ("Per Bank Refresh is only allowed in devices with 8 banks");
                    end else if (bank_active[bank_ref]) begin
                        $sformat (msg, "Bank %d must be Precharged prior to REFpb", bank_ref);
                        ERROR (msg);
                    end else begin
                        // a maximum of 4 REFpb commands may be issued in any rolling tFAW
                        j = 0;
                        for (i=0; i<(1<<BA_BITS); i=i+1) begin
                            if ((ck_cntr - ck_bank_ref[i] < FAW) || ($time - tm_bank_ref[i] < TFAW)) begin
                                j = j + 1;
                            end
                        end
                        if (j > 4) begin
                            ERROR ("tFAW violation");
                        end
                        $sformat (msg, "REFpb bank %d", bank_ref);
                        INFO (msg);
                        bank_ref <= bank_ref + 1;
                        ck_ref <= ck_cntr;
                        tm_ref <= $time;
                        ck_bank_ref[bank_ref] <= ck_cntr;
                        tm_bank_ref[bank_ref] <= $time;
                    end
                end
                {1'b1, REFAB_CMD} : begin
                    if (|init) begin
                        ERROR ("Initialization sequence must be complete prior to REFab");
                    end else if (|bank_active) begin
                        ERROR ("All banks must be Precharged prior to REFab");
                    end else begin
                        // a maximum of 8 REFab commands may be issued in any rolling tREFBW
                        j = 0;
                        for (i=0; i<16; i=i+1) begin
                            if ($time - tm_burst_refa[i] < TREFBW) begin
                                j = j + 1;
                            end
                        end
                        if (j > 8) begin
                            ERROR ("tREFBW violation");
                        end
                        INFO ("REFab");
                        bank_ref <= 0; // REFAB reset bank_ref counter
                        burst_refa <= burst_refa + 1;
                        tm_refa <= $time;
                        tm_burst_refa[burst_refa] <= $time;
                    end
                end
                {1'b1, ACT_CMD} : begin
                    if (|init) begin
                        ERROR ("Initialization sequence must be complete prior to ACT");
                    end else if (bank_active[ba]) begin
                        $sformat (msg, "Bank %d must be Precharged prior to ACT", ba);
                        ERROR (msg);
                    end else begin
                        // a maximum of 4 Act commands may be issued in any rolling tFAW
                        j = 0;
                        for (i=0; i<(1<<BA_BITS); i=i+1) begin
                            if ((ck_cntr - ck_bank_act[i] < FAW) || ($time - tm_bank_act[i] < TFAW)) begin
                                j = j + 1;
                            end
                        end
                        if (j > 4) begin
                            ERROR ("tFAW violation");
                        end
                        neg_en <= 1'b1;
                        ck_act <= ck_cntr;
                        tm_act <= $time;
                        ck_bank_act[ba] <= ck_cntr;
                        tm_bank_act[ba] <= $time;
                    end 
                end
                {1'b1, WRITE_CMD} : begin
                    if (|init) begin
                        ERROR ("Initialization sequence must be complete prior to WRITE");
                    end else if (!bank_active[ba]) begin
                        $sformat (msg, "Bank %d must be Activated prior to WRITE", ba);
                        WARN (msg); // change from ERR to WAR
                    end else if (bank_ap[ba]) begin
                        $sformat (msg, "Auto Precharge is scheduled to bank %d", ba);
                        ERROR (msg);
                    end else if ((ck_write > ck_bst) && (ck_cntr - ck_write < lastwr_bl/2) && (ck_cntr - ck_write)%(SX/2)) begin
                        ERROR ("Illegal WRITE bust interruption");
                    end else begin
                        neg_en <= 1'b1;
                        cas_ba <= ba;
                        ck_write <= ck_cntr;
                        ck_write_end <= ck_cntr;
                        ck_bank_write[ba] <= ck_cntr;
                        ck_bank_write_end[ba] <= ck_cntr;
                        tm_write_end <= $time;
                        tm_bank_write_end[ba] <= $time;
                    end
                end
                {1'b1, READ_CMD} : begin
                    if (|init) begin
                        ERROR ("Initialization sequence must be complete prior to READ");
                    end else if (!bank_active[ba]) begin
                        $sformat (msg, "Bank %d must be Activated prior to READ", ba);
                        WARN (msg); // change from ERROR to WARN
                    end else if (bank_ap[ba]) begin
                        $sformat (msg, "Auto Precharge is scheduled to bank %d", ba);
                        ERROR (msg);
                    end else if ((ck_read > ck_bst) && (ck_cntr - ck_read < lastrd_bl/2) && (ck_cntr - ck_read)%(SX/2)) begin
                        ERROR ("Illegal READ burst interruption");
                    end else begin
                        neg_en <= 1'b1;
                        cas_ba <= ba;
                        ck_read <= ck_cntr;
                        ck_read_end <= ck_cntr;
                        ck_bank_read[ba] <= ck_cntr;
                        ck_bank_read_end[ba] <= ck_cntr;
                        tm_read_end <= $time;
                        tm_bank_read_end[ba] <= $time;
                    end
                end
                {1'b1, BST_CMD} : begin
                    if (|init) begin
                        ERROR ("Initialization sequence must be complete prior to BST");
                    end else if ((ck_cntr - ck_write >= lastwr_bl/2) && (ck_cntr - ck_read >= lastrd_bl/2)) begin
                        // ERROR ("BST may only be issued up to BL/2 - 1 clock cycles after a READ or WRITE"); // CHECK OFF 
                    end else if ((ck_read > ck_write) && (ck_cntr - ck_read)%(SX/2)) begin
                        ERROR ("BST can only be issued an even number of clock cycles after a READ");
                    end else if ((ck_write > ck_read) && (ck_cntr - ck_write)%(SX/2)) begin
                        ERROR ("BST can only be issued an even number of clock cycles after a WRITE");
                    end else if (bank_ap[cas_ba]) begin
                        $sformat (msg, "Auto Precharge is scheduled to bank %d", cas_ba);
                        ERROR (msg);
                    end else begin
                        INFO ("BST");
                        wr_pipeline <= (wr_pipeline>>1) & ((1<<(wl + 1))-1);
                        rd_pipeline <= (rd_pipeline>>1) & ((1<<(rl - 1))-1);
                        ck_bst <= ck_cntr;
                    end
                end
                {1'b1, PRE_CMD} : begin
                    // A PRECHARGE command will be treated as a NOP if there is no open row in that bank (idle state), 
                    // or if the previously open row is already in the process of precharging.
                    if (ab) begin
                        if (|init) begin
                            ERROR ("Initialization sequence must be complete prior to PREab");
                        end else if (&(~bank_active | bank_ap)) begin
                            INFO ("PREab has been ignored");
                        end else begin
                            INFO ("PREab");
                            bank_active = 0;
                            ck_prea <= ck_cntr;
                            tm_prea <= $time;
                        end
                    end else if (bank_active[ba]) begin
                        if (|init) begin
                            ERROR ("Initialization sequence must be complete prior to PREpb");
                        end else if (~bank_active[ba] | bank_ap[ba]) begin
                            $sformat (msg, "PREpb bank %d has been ignored", ba);
                            INFO (msg);
                        end else begin
                            $sformat (msg, "PREpb bank %d", ba);
                            INFO (msg);
                            ck_pre <= ck_cntr;
                            tm_pre <= $time;
                            bank_active[ba] = 1'b0;
                            ck_bank_pre[ba] <= ck_cntr;
                            tm_bank_pre[ba] <= $time;
                        end
                    end
                end
                {1'b1, NOP_CMD} : ; // do nothing
                {1'b1, SREF_CMD} : begin
                    if (|init) begin
                        ERROR ("Initialization sequence must be complete prior to SREF");
                    end else if (|bank_active) begin
                        ERROR ("All banks must be Precharged prior to SREF");
                    end else begin
                        INFO ("SREF");
                        cke_cmd <= SREF_CMD>>1;
                        bank_ref <= 0;
                        ck_cke <= ck_cntr;
                        tm_cke <= $time;

		        // odt
		        fork begin
			   odt_pincontrol_semaphore = 1; // SREF
			   #(TDQSCK_MIN-300);
			   if (odt_pincontrol_semaphore == 1 && odt_pincontrol)  
			     odt_pincontrol = 1'bx;
			   #(TDQSCK_MAX+(tck_i>3000?tck_i:3000)-(TDQSCK_MIN-300));
			   if (odt_pincontrol_semaphore == 1) 
			     odt_pincontrol = 1'b0;
			end
			join_none
                    end
                end
                {1'b1, DPD_CMD} : begin
                    if (|init) begin
                        ERROR ("Initialization sequence must be complete prior to DPD");
                    end else begin
                        INFO ("DPD");
                        init <= 1;
                        bank_active <= 0; // allow MRW(RESET) command
                        cke_cmd <= DPD_CMD>>1;
`ifdef MAX_MEM
                        erase_banks({(1<<BA_BITS){1'b1}});
`else
                        memory_used <= 0;
`endif
                        ck_cke <= ck_cntr;
                        tm_cke <= $time;

		        // odt
			fork begin
			   odt_pincontrol_semaphore = 2; // DPD
			   #(TDQSCK_MIN-300);
			   if (odt_pincontrol_semaphore == 2 && odt_pincontrol)  
			     odt_pincontrol = 1'bx;
			   #(TDQSCK_MAX+(tck_i>3000?tck_i:3000)-(TDQSCK_MIN-300));
			   if (odt_pincontrol_semaphore == 2) 
			     odt_pincontrol = 1'b0;
			end
			join_none
                    end
                end
                {1'b1, PD_CMD} : begin
                    if (|init && (init < 5)) begin
                        ERROR ("PD is illegal until tINIT4 has been satisfied");
                    end else if ((ck_cntr - ck_mrr < MRR) || (ck_cntr - ck_mrw < MRW)) begin
                        ERROR ("CKE is not allowed to go LOW while MRR or MRW operations are in progress");
                    end else begin
                        $sformat (msg, "PD active = %d", |bank_active);
                        INFO (msg);
                        cke_cmd <= PD_CMD>>1;
                        ck_cke <= ck_cntr;
                        tm_cke <= $time;

		        // odt
		        if (!rtt_mode_reg[2])
			  fork begin
			     odt_pincontrol_semaphore = 3; // PD
			     #(TDQSCK_MIN-300);
			     if (odt_pincontrol_semaphore == 3 && odt_pincontrol)  
			       odt_pincontrol = 1'bx;
			     #(TDQSCK_MAX+(tck_i>3000?tck_i:3000)-(TDQSCK_MIN-300));
			     if (odt_pincontrol_semaphore == 3) 
			       odt_pincontrol = 1'b0;
			  end
			  join_none
                    end
                end
                {1'b0, NOP_CMD} : begin // EXIT SREF, PD, DPD
                    case (cke_cmd)
                        SREF_CMD>>1 : begin 
                            if ($time - tm_cke < TCKESR) 
                                ERROR ("tCKESR violation"); 
                            ck_sref <= ck_cntr;
                            tm_sref <= $time;

		            // odt
			    if (rtt_mode_reg[1:0]) begin
			       fork begin
				  odt_pincontrol_semaphore = 4; // SREF Exit
				  odt_pincontrol = 1'bx;
				  #(TXSR);
				  if (odt_pincontrol_semaphore == 4) 
				    odt_pincontrol = 1'b1;
			       end
			       join_none
			    end
                        end
                        DPD_CMD>>1  ,
                        PD_CMD>>1   : begin 
                            ck_pd <= ck_cntr; 
                            tm_pd <= $time; 

		            // odt
			    if (rtt_mode_reg[1:0]) begin
			       fork begin
				  odt_pincontrol_semaphore = 5; // PDE Exit
				  odt_pincontrol = 1'bx;
				  #(tck_i<TXP/3 ? TXP+3500 : tck_i*3+3500);
				  if (odt_pincontrol_semaphore == 5) 
				    odt_pincontrol <= 1'b1;
			       end
			       join_none
			    end
                        end
                    endcase
                    if (ck_cntr - ck_cke < CKE) 
                        ERROR ("tCKE violation");
                    ck_cke <= ck_cntr;
                    tm_cke <= $time;
                end
                6'b00xxxx : begin // Maintain SREF, PD, DPD
                    if ((ck_cntr - ck_cke == 1) && (cmd[3:1] !== 3'b111)) begin
                        ERROR ("Nop or Deselect must be driven in the clock cycle after CKE goes low");
                    end
                end
                default : ERROR ("Illegal command");
            endcase

            cke_q <= cke_in;
            ca_q <= ca;
            ck_cntr <= ck_cntr + 1;
            tck_i <= $time - tm_ck_pos;    
            tm_ck_pos <= $time;

        end else  begin
	   tm_ck_hi <= $time - tm_ck_pos;

	   if (ca_neg_en) begin
	      // CA Train cmd
	      dq_out_en <= #TADR 1'b1;
	      dq_out <= #TADR 1'b0; // unused dq defaults to zero
	      if (ca_train==3) begin // MODE 41
		 dq_out[0] <= #TADR ca_q[0];
		 dq_out[2] <= #TADR ca_q[1];
		 dq_out[4] <= #TADR ca_q[2];
		 dq_out[6] <= #TADR ca_q[3];
		 dq_out[8] <= #TADR ca_q[5];
		 dq_out[10] <= #TADR ca_q[6];
		 dq_out[12] <= #TADR ca_q[7];
		 dq_out[14] <= #TADR ca_q[8];
		 dq_out[1] <= #TADR ca[0];
		 dq_out[3] <= #TADR ca[1];
		 dq_out[5] <= #TADR ca[2];
		 dq_out[7] <= #TADR ca[3];
		 dq_out[9] <= #TADR ca[5];
		 dq_out[11] <= #TADR ca[6];
		 dq_out[13] <= #TADR ca[7];
		 dq_out[15] <= #TADR ca[8];
	      end
	      else begin // MODE 48
		 dq_out[0] <= #TADR ca_q[4];
		 dq_out[8] <= #TADR ca_q[9];
		 dq_out[1] <= #TADR ca[4];
		 dq_out[9] <= #TADR ca[9];
	      end

	      dqs_out_ca_en <= #TADR 1'b1;
	      dqs_out_ca <= #TADR 1'b0; // unused dqs defaults to zero
	      dqs_out_ca_n <= #TADR 1'b0; // unused dqs defaults to zero

	      ca_neg_en <= 1'b0;
	   end

           if (neg_en) begin
              ma = {ca[1:0], ca_q[9:4]};
              op = ca[9:2];
              ba = ca_q[9:7];
              r = {ca[9:8], ca_q[6:2], ca[7:0]};
              c = {ca[9:1], ca_q[6:5], 1'b0};
              ecbbl = {ca_q[3], ca_q[4]};
              casex ({ca_q[0], ca_q[1], ca_q[2]})
                3'b000 : begin // MRW/MRR
                   if (ca_q[3]) begin // MRR
                      if (mrwe[ma]) begin
                         $sformat (msg, "Register %d is Write Only", ma); 
                         WARN (msg);
                      end
		      // still output data for write only registers 
                      $sformat (msg, "MRR ma %h op %h", ma, mr[ma]);
                      INFO (msg);
                      for (i=0; i<4; i=i+1) begin
                         rd_pipeline[rl - 1 + i] <= 1'b1;
                         ba_pipeline[rl - 1 + i] <= {BA_BITS{1'bx}};
                         ma_pipeline[rl - 1 + i] <= ma + i*256;
                      end
                   end else begin // MRW
                      if (~mrwe[ma]) begin
                         $sformat (msg, "Register %d is Read Only or RFU", ma); 
                         WARN (msg);
                      end else begin
                         if (~mrmask[ma] & op) begin
                            $sformat(msg, "RFU bits in ma %h cannot be set", ma);
                            WARN (msg);
                         end
                         if (ma == 10) begin
                            tm_zq <= tm_ck_pos;
                         end
                         $sformat (msg, "MRW ma %h op %h", ma, op);
                         INFO (msg);
                         mr[ma] <= mrmask[ma] & op;
                      end
                   end
                end
                3'b01x : begin // ACT
                   if (r >= 1<<ROW_BITS) begin
                      $sformat (msg, "row = %h does not exist.  Maximum row = %h", r, (1<<ROW_BITS)-1);
                      WARN (msg);
                   end
                   $sformat (msg, "ACT bank %d row %h", ba, r);
                   INFO (msg);
                   bank_active[ba] = 1'b1;
                   row_active[ba] = r;
                end
                3'b100 : begin // WRITE
                   if (c >= 1<<COL_BITS) begin
                      $sformat (msg, "col = %h does not exist.  Maximum col = %h", c, (1<<COL_BITS)-1);
                      WARN (msg);
                   end
                   $sformat (msg, "WRITE bank %d col %h ap %d", ba, c, ca[0]);
                   INFO (msg);
		   bl = updatebl(ecbbl);
		   lastwr_bl = bl;
                   for (i=0; i<bl/2; i=i+1) begin
                      wr_pipeline[wl + 1 + i] <= 1'b1;
                      ba_pipeline[wl + 1 + i] <= ba;
                      row_pipeline[wl + 1 + i] <= row_active[ba];
                      col_pipeline[wl + 1 + i] <= (c & -1*bl) + (c%bl + 2*i)%(bl); // sequential
                   end
                   bank_ap[ba] <= ca[0]; // AP
                   write_ap[ba] <= ca[0]; // AP
                end
                3'b101 : begin // READ
                   if (c >= 1<<COL_BITS) begin
                      $sformat (msg, "col = %h does not exist.  Maximum col = %h", c, (1<<COL_BITS)-1);
                      WARN (msg);
                   end
                   $sformat (msg, "READ bank %d col %h ap %d", ba, c, ca[0]);
                   INFO (msg);
		   bl = updatebl(ecbbl);
		   lastrd_bl = bl;
                   for (i=0; i<bl/2; i=i+1) begin
                      rd_pipeline[rl - 1 + i] <= 1'b1;
                      ba_pipeline[rl - 1 + i] <= ba;
                      row_pipeline[rl - 1 + i] <= row_active[ba];
                      col_pipeline[rl - 1 + i] <= (c & -1*bl) + (c%bl + 2*i)%(bl); // sequential
                   end
                   bank_ap[ba] <= ca[0]; // AP
                   read_ap[ba] <= ca[0]; // AP
                end
              endcase
              neg_en <= 1'b0;
           end
	end

        if (!ca_train && !writeleveling) begin
           // write data
           ba = ba_pipeline[0];
           r = row_pipeline[0];
           c = col_pipeline[0] + diff_ck;
           ma = ma_pipeline[0] + diff_ck;
           if (wr_pipeline[0]) begin
              bit_mask = 0;
              if (diff_ck) begin
                 for (i=0; i<DM_BITS; i=i+1) begin
                    bit_mask = bit_mask | ({`DQ_PER_DQS{~dm_in_neg[i]}}<<(DQ_BITS + i*`DQ_PER_DQS));
                 end
                 memory_data = ((dq_in_neg<<DQ_BITS) & bit_mask) | (memory_data & ~bit_mask);
                 memory_write(ba, r, c, memory_data);
              end else begin
                 for (i=0; i<DM_BITS; i=i+1) begin
                    bit_mask = bit_mask | ({`DQ_PER_DQS{~dm_in_pos[i]}}<<(i*`DQ_PER_DQS));
                 end
                 memory_read(ba, r, c, memory_data);
                 memory_data = (dq_in_pos & bit_mask) | (memory_data & ~bit_mask);
              end
              dq_temp = memory_data>>(c[0]*DQ_BITS);
              $sformat (msg, "Write @dqs, bank = %h, row = %h, col = %h, dq = %h", ba, r, c, dq_temp);
              INFO (msg);
           end

           // read data
           if (diff_ck) begin
	      odt_rd_dis <= #(TDQSCK-300) (|{rd_pipeline[2:0],rd_pipeline_prevbit0});
              dqs_out_en <= #(TDQSCK) (|rd_pipeline[1:0]);
              dq_out_en <= #(TDQSCK) (rd_pipeline[0]);
	      rd_pipeline_prevbit0 = rd_pipeline[0];
           end
           dqs_out <= #(TDQSCK) rd_pipeline[0] && diff_ck;
           dq_out <= #(TDQSCK) dq_temp;

           if (rd_pipeline[0]) begin
              if (!diff_ck) begin
                 if (ba === {BA_BITS{1'bx}}) begin // MRR command
                    if(ma==32 || ma==(32+256) || ma==(32+2*256) || ma==(32+3*256)) begin
                       memory_data = {{DQ_BITS{1'b0}},{DQ_BITS{1'b1}}};
                    end
                    else if (ma==40 || ma==(40+2*256)) begin
                       memory_data = {{DQ_BITS{1'b0}},{DQ_BITS{1'b0}}};
                    end
                    else if (ma==(40+256) || ma==(40+3*256)) begin
                       memory_data = {{DQ_BITS{1'b1}},{DQ_BITS{1'b1}}};
                    end
		    else if (ma<256)
                      memory_data = {{2*DQ_BITS - 8{MRRBIT}}, mr[ma]};
		    else
                      memory_data = {2*DQ_BITS{MRRBIT}};
                 end else begin
                    memory_read(ba, r, c, memory_data);
                 end
              end

              if (ba === {BA_BITS{1'bx}}) // MRR command // no need to shift for MRR
              dq_temp = memory_data>>(diff_ck*DQ_BITS);
              else
		dq_temp = memory_data>>(c[0]*DQ_BITS);

              $sformat (msg, "Read @dqs, bank = %h, row = %h, col = %h, dq = %h", ba, r, c, dq_temp);
              INFO (msg);
           end
	end
    end 

    // receiver(s)
    task dqs_even_receiver;
        input [3:0] i;
        reg [63:0] bit_mask;
        begin
	   // 0->1 edge only
	   if (~dqs_even_prev[i] && dqs_even[i]) begin
              bit_mask = {`DQ_PER_DQS{1'b1}}<<(i*`DQ_PER_DQS);
              if (dqs_even[i]) begin
                 dm_in_pos[i] = dm_in[i];
                 dq_in_pos = (dq_in & bit_mask) | (dq_in_pos & ~bit_mask);
              end
	      if (writeleveling && dqs_even[i]) begin
		 int k;
		 if ($time - tm_writelevel_start < TWLMRD) ERROR ("tWLMRD violation"); 
		 dq_out_en <= #TWLO 1'b1;
		 for(k=0; k<`DQ_PER_DQS; k++)
		   dq_out[k+i*`DQ_PER_DQS] <= #TWLO ck;
	      end
	   end
	   dqs_even_prev[i] = dqs_even[i];
        end
    endtask

    always @(dqs_even[ 0]) dqs_even_receiver( 0);
    always @(dqs_even[ 1]) dqs_even_receiver( 1);
    always @(dqs_even[ 2]) dqs_even_receiver( 2);
    always @(dqs_even[ 3]) dqs_even_receiver( 3);
    always @(dqs_even[ 4]) dqs_even_receiver( 4);
    always @(dqs_even[ 5]) dqs_even_receiver( 5);
    always @(dqs_even[ 6]) dqs_even_receiver( 6);
    always @(dqs_even[ 7]) dqs_even_receiver( 7);

    task dqs_odd_receiver;
        input [3:0] i;
        reg [63:0] bit_mask;
        begin
	   // 0->1 edge only
	   if (~dqs_odd_prev[i] && dqs_odd[i]) begin
              bit_mask = {`DQ_PER_DQS{1'b1}}<<(i*`DQ_PER_DQS);
              if (dqs_odd[i]) begin
                 dm_in_neg[i] = dm_in[i];
                 dq_in_neg = (dq_in & bit_mask) | (dq_in_neg & ~bit_mask);
              end
	      if (writeleveling  && dqs_odd[i]) 
		if ($time - tm_writelevel_start < TWLDQSEN) ERROR ("tWLDQSEN violation"); 
	   end
	   dqs_odd_prev[i] = dqs_odd[i];
        end
    endtask

    always @(dqs_odd[ 0]) dqs_odd_receiver( 0);
    always @(dqs_odd[ 1]) dqs_odd_receiver( 1);
    always @(dqs_odd[ 2]) dqs_odd_receiver( 2);
    always @(dqs_odd[ 3]) dqs_odd_receiver( 3);
    always @(dqs_odd[ 4]) dqs_odd_receiver( 4);
    always @(dqs_odd[ 5]) dqs_odd_receiver( 5);
    always @(dqs_odd[ 6]) dqs_odd_receiver( 6);
    always @(dqs_odd[ 7]) dqs_odd_receiver( 7);

    // odt 
    always @(odt or rtt_mode_reg[1:0]) 
      if (odt===1'b1 && rtt_mode_reg[1:0])  begin
	 case (rtt_mode_reg[1:0])
	   2'b01: begin 
	      rtt_sync_val <= #(1.75ns) 16'bx; 
	      rtt_sync_val <= #(3.5ns) 60;
	   end
	   2'b10: begin 
	      rtt_sync_val <= #(1.75ns) 16'bx; 
	      rtt_sync_val <= #(3.5ns) 120;
	   end
	   2'b11: begin 
	      rtt_sync_val <= #(1.75ns) 16'bx; 
	      rtt_sync_val <= #(3.5ns) 240;
	   end
	 endcase
      end
      else begin
	 rtt_sync_val <= #(1.75ns) 16'bx; 
	 rtt_sync_val <= #(3.5ns) 16'bz;
      end

    always @(rtt_sync_val or odt_pincontrol) begin
       if (odt_pincontrol===1'bx) begin
	  rtt_val <= #(1ps) 16'bx;
       end
       else if (odt_pincontrol===1'b0) begin
	  rtt_val <= #(1ps) 16'bz;
       end
       else if (odt_pincontrol===1'b1) begin
	  rtt_val <= #(1ps) rtt_sync_val;
       end
    end

    //---------------------------------------------------
    // TASK: INFO("msg")
    //---------------------------------------------------
    task INFO;
        input [MSGLENGTH*8:1] msg;
        begin
            $fdisplay(mcd_info, "%m at time %t: %0s", $time, msg);
        end
    endtask

    //---------------------------------------------------
    // TASK: WARN("msg")
    //---------------------------------------------------
    task WARN;
        input [MSGLENGTH*8:1] msg;
        begin
            $fdisplay(mcd_warn, "%m at time %t: %0s", $time, msg);
            warnings = warnings + 1;
        end
    endtask

    //---------------------------------------------------
    // TASK: ERROR(errcode, "msg")
    //---------------------------------------------------
    task ERROR;
        input [MSGLENGTH*8:1] msg;
        begin
            $fdisplay(mcd_error, "%m at time %t: %0s", $time, msg);
            errors = errors + 1;
            if (STOP_ON_ERROR) begin
                STOP;
            end
        end
    endtask

    //---------------------------------------------------
    // TASK: FAIL("msg")
    //---------------------------------------------------
    task FAIL;
        input [MSGLENGTH*8:1] msg;
        begin
            $fdisplay(mcd_fail, "%m at time %t: %0s", $time, msg);
            failures = failures + 1;
            STOP;
        end
    endtask

    //---------------------------------------------------
    // TASK: Stop()
    //---------------------------------------------------
    task STOP;
        begin
            $display("%m at time %t: %d warnings, %d errors, %d failures", $time, warnings, errors, failures);
            $stop(0);
        end
    endtask


    function integer ceil;
        input number;
        real number;
        if (number > $rtoi(number))
            ceil = $rtoi(number) + 1;
        else
            ceil = number;
    endfunction

`ifdef MAX_MEM
    function integer open_bank_file( input integer bank );
        integer fd;
        reg [2048:1] filename;
        begin
            $sformat( filename, "%0s/%m.%0d", tmp_model_dir, bank );

            fd = $fopen(filename, "w+");
            if (fd == 0)
            begin
	        if (mcd_error)
                  $display("%m: at time %0t ERROR: failed to open %0s.", $time, filename);
                $finish;
            end
            else
            begin
	        if (mcd_info) 
		  $display("%m: at time %0t INFO: opening %0s.", $time, filename);
                open_bank_file = fd;
            end

        end
    endfunction

    function [2*RFF_BITS:1] read_from_file(
        input integer fd,
        input integer index
    );
        integer code;
        integer offset;
        reg [1024:1] msg;
        reg [2*RFF_BITS:1] read_value;

        begin
            offset = index * RFF_CHUNK;
            code = $fseek( fd, offset, 0 );
            // $fseek returns 0 on success, -1 on failure
            if (code != 0)
            begin
                $display("%m: at time %t ERROR: fseek to %d failed", $time, offset);
                $finish;
            end

            code = $fscanf(fd, "%z", read_value);
            // $fscanf returns number of items read
            if (code != 1)
            begin
                if ($ferror(fd,msg) != 0)
                begin
                    $display("%m: at time %t ERROR: fscanf failed at %d", $time, index);
                    $display(msg);
                    $finish;
                end
                else
                    read_value = 'hx;
            end

            /* when reading from unwritten portions of the file, 0 will be returned.
            * Use 0 in bit 1 as indicator that invalid data has been read.
            * A true 0 is encoded as Z.
            */
            if (read_value[1] === 1'bz)
                // true 0 encoded as Z, data is valid
                read_value[1] = 1'b0;
            else if (read_value[1] === 1'b0)
                // read from file section that has not been written
                read_value = 'hx;

            read_from_file = read_value;
        end
    endfunction

    task write_to_file(
        input integer fd,
        input integer index,
        input [2*RFF_BITS:1] data
    );
        integer code;
        integer offset;

        begin
            offset = index * RFF_CHUNK;
            code = $fseek( fd, offset, 0 );
            if (code != 0)
            begin
                $display("%m: at time %t ERROR: fseek to %d failed", $time, offset);
                $finish;
            end

            // encode a valid data
            if (data[1] === 1'bz)
                data[1] = 1'bx;
            else if (data[1] === 1'b0)
                data[1] = 1'bz;

            $fwrite( fd, "%z", data );
        end
    endtask

    task erase_banks;
        input  [(1<<BA_BITS)-1:0] banks; //one select bit per bank
        integer bank;

        begin

        for (bank = 0; bank < (1<<BA_BITS); bank = bank + 1)
            if (banks[bank] === 1'b1) begin
                $fclose(memfd[bank]);
                memfd[bank] = open_bank_file(bank);
            end
        end
    endtask
`else
    function get_index;
        input [`MAX_BITS-1:0] addr;
        begin : index
            get_index = 0;
            for (memory_index=0; memory_index<memory_used; memory_index=memory_index+1) begin
                if (address[memory_index] == addr) begin
                    get_index = 1;
                    disable index;
                end
            end
        end
    endfunction
`endif

    task memory_write;
        input  [BA_BITS-1:0]  bank;
        input  [ROW_BITS-1:0] row;
        input  [COL_BITS-1:0] col;
        input  [2*DQ_BITS-1:0] data;
        reg    [`MAX_BITS-1:0] addr;
        begin
            // chop off the lowest address bits
            addr = {bank, row, col}/2;
`ifdef MAX_MEM
            write_to_file( memfd[bank], {row, col}/2, data );
`else
            if (get_index(addr)) begin
                address[memory_index] = addr;
                memory[memory_index] = data;
            end else if (memory_used == `MEM_SIZE) begin
                $display ("%m: at time %t ERROR: Memory overflow.  Write to Address %h with Data %h will be lost.\nYou must increase the MEM_BITS parameter or define MAX_MEM.", $time, addr, data);
                if (STOP_ON_ERROR) $stop(0);
            end else begin
                address[memory_used] = addr;
                memory[memory_used] = data;
                memory_used = memory_used + 1;
            end
`endif
        end
    endtask

    task memory_read;
        input  [BA_BITS-1:0]  bank;
        input  [ROW_BITS-1:0] row;
        input  [COL_BITS-1:0] col;
        output [2*DQ_BITS-1:0] data;
        reg    [`MAX_BITS-1:0] addr;
        begin
            // chop off the lowest address bits
            addr = {bank, row, col}/2;
`ifdef MAX_MEM
            data = read_from_file( memfd[bank], {row, col}/2 );
`else
            if (get_index(addr)) begin
                data = memory[memory_index];
            end else begin
                data = {2*DQ_BITS{1'bx}};
            end
`endif
        end
    endtask


endmodule

`ifdef LPDDR3_2_1
module mobile_ddr3_2_1 (
    ck,
    ck_n,
    cke,
    cs_n,
    ca,
    dm,
    dq,
    dqs,
    dqs_n,
    odt
);

    `include "mobile_ddr3_parameters.vh"

    // ports
    input                       ck;
    input                       ck_n;
    input                 [1:0] cke;
    input                 [1:0] cs_n;
    input         [CA_BITS-1:0] ca;
    input         [DM_BITS-1:0] dm;
    inout         [DQ_BITS-1:0] dq;
    inout        [DQS_BITS-1:0] dqs;
    inout        [DQS_BITS-1:0] dqs_n;

    mobile_ddr3 sdrammobile_ddr3_0 (
        ck,
        ck_n,
        cke[0],
        cs_n[0],
        ca,
        dm,
        dq,
        dqs,
        dqs_n,
        odt

    );
    
    mobile_ddr3 sdrammobile_ddr3_1 (
        ck,
        ck_n,
        cke[1],
        cs_n[1],
        ca,
        dm,
        dq,
        dqs,
        dqs_n,
        odt
    );
   
endmodule
`endif 

`ifdef LPDDR3_2_2
module mobile_ddr3_2_2 (
    ck,
    ck_n,
    cke,
    cs_n,
    ca,
    dm,
    dq,
    dqs,
    dqs_n,
    odt
);

    `include "mobile_ddr3_parameters.vh"

    // ports
    input                       ck;
    input                       ck_n;
    input                       cke;
    input                       cs_n;
    input           [CA_BITS-1:0] ca;
    input         [2*DM_BITS-1:0] dm;
    inout         [2*DQ_BITS-1:0] dq;
    inout        [2*DQS_BITS-1:0] dqs;
    inout        [2*DQS_BITS-1:0] dqs_n;

    mobile_ddr3 sdrammobile_ddr3_0 (
        ck,
        ck_n,
        cke,
        cs_n,
        ca,
        dm[DM_BITS-1:0],
        dq[DQ_BITS-1:0],
        dqs[DQS_BITS-1:0],
        dqs_n[DQS_BITS-1:0],
	odt
    );
    
    mobile_ddr3 sdrammobile_ddr3_1 (
        ck,
        ck_n,
        cke,
        cs_n,
        ca,
        dm[2*DM_BITS-1:DM_BITS],
        dq[2*DQ_BITS-1:DQ_BITS],
        dqs[2*DQS_BITS-1:DQS_BITS],
        dqs_n[2*DQS_BITS-1:DQS_BITS],
	odt
    );
   
endmodule
`endif

`ifdef LPDDR3_4_2
module mobile_ddr3_4_2 (
    ck,
    ck_n,
    cke,
    cs_n,
    ca,
    dm,
    dq,
    dqs,
    dqs_n,
    odt
);

    `include "mobile_ddr3_parameters.vh"

    // ports
    input                       ck;
    input                       ck_n;
    input                 [1:0] cke;
    input                 [1:0] cs_n;
    input         [CA_BITS-1:0] ca;
    input         [2*DM_BITS-1:0] dm;
    inout         [2*DQ_BITS-1:0] dq;
    inout        [2*DQS_BITS-1:0] dqs;
    inout        [2*DQS_BITS-1:0] dqs_n;

    mobile_ddr3 sdrammobile_ddr3_0_0 (
        ck,
        ck_n,
        cke[0],
        cs_n[0],
        ca,
        dm[DM_BITS-1:0],
        dq[DQ_BITS-1:0],
        dqs[DQS_BITS-1:0],
        dqs_n[DQS_BITS-1:0],
	odt
    );
    
    mobile_ddr3 sdrammobile_ddr3_0_1 (
        ck,
        ck_n,
        cke[0],
        cs_n[0],
        ca,
        dm[2*DM_BITS-1:DM_BITS],
        dq[2*DQ_BITS-1:DQ_BITS],
        dqs[2*DQS_BITS-1:DQS_BITS],
        dqs_n[2*DQS_BITS-1:DQS_BITS],
	odt
    );

    mobile_ddr3 sdrammobile_ddr3_1_0 (
        ck,
        ck_n,
        cke[1],
        cs_n[1],
        ca,
        dm[DM_BITS-1:0],
        dq[DQ_BITS-1:0],
        dqs[DQS_BITS-1:0],
        dqs_n[DQS_BITS-1:0],
	odt
    );

    mobile_ddr3 sdrammobile_ddr3_1_1 (
        ck,
        ck_n,
        cke[1],
        cs_n[1],
        ca,
        dm[2*DM_BITS-1:DM_BITS],
        dq[2*DQ_BITS-1:DQ_BITS],
        dqs[2*DQS_BITS-1:DQS_BITS],
        dqs_n[2*DQS_BITS-1:DQS_BITS],
	odt
    );
   
endmodule
`endif

