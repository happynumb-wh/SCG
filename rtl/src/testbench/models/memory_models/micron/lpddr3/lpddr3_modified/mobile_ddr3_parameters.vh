/****************************************************************************************
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
*                Copyright 2011 Micron Technology, Inc. All rights reserved.
*
****************************************************************************************/


    // Timing parameters based on Speed Grade

                                              // SYMBOL UNITS DESCRIPTION
                                              // ------ ----- -----------
    parameter mcd_info = 0;
`ifdef sg3
    parameter TCK_MIN           =       3000; // tCK      ps  Minimum Clock Cycle Time
    parameter TDQSQ             =        280; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TDS               =        350; // tDS      ps  DQ and DM input setup time relative to DQS
    parameter TDH               =        350; // tDH      ps  DQ and DM input hold time relative to DQS
    parameter TIS               =        370; // tIS      ps  Input Setup Time
    parameter TIH               =        370; // tIH      ps  Input Hold Time
    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay
`else `ifdef sg93
    parameter TCK_MIN           =        938; // tCK      ps  Minimum Clock Cycle Time
    parameter TDQSQ             =        200; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TDS               =        150; // tDS      ps  DQ and DM input setup time relative to DQS
    parameter TDH               =        150; // tDH      ps  DQ and DM input hold time relative to DQS
    parameter TIS               =        150; // tIS      ps  Input Setup Time
    parameter TIH               =        150; // tIH      ps  Input Hold Time
    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay
`else `ifdef sg107
    parameter TCK_MIN           =        1072; // tCK      ps  Minimum Clock Cycle Time
    parameter TDQSQ             =        200; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TDS               =        150; // tDS      ps  DQ and DM input setup time relative to DQS
    parameter TDH               =        150; // tDH      ps  DQ and DM input hold time relative to DQS
    parameter TIS               =        150; // tIS      ps  Input Setup Time
    parameter TIH               =        150; // tIH      ps  Input Hold Time
    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay
`else `ifdef sg125
    parameter TCK_MIN           =       1250; // tCK      ps  Minimum Clock Cycle Time
    parameter TDQSQ             =        200; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TDS               =        150; // tDS      ps  DQ and DM input setup time relative to DQS
    parameter TDH               =        150; // tDH      ps  DQ and DM input hold time relative to DQS
    parameter TIS               =        150; // tIS      ps  Input Setup Time
    parameter TIH               =        150; // tIH      ps  Input Hold Time
    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay
`else `ifdef sg136
    parameter TCK_MIN           =       1360; // tCK      ps  Minimum Clock Cycle Time
    parameter TDQSQ             =        200; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TDS               =        150; // tDS      ps  DQ and DM input setup time relative to DQS
    parameter TDH               =        150; // tDH      ps  DQ and DM input hold time relative to DQS
    parameter TIS               =        150; // tIS      ps  Input Setup Time
    parameter TIH               =        150; // tIH      ps  Input Hold Time
    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay
`else `ifdef sg15
    parameter TCK_MIN           =       1500; // tCK      ps  Minimum Clock Cycle Time
    parameter TDQSQ             =        200; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TDS               =        175; // tDS      ps  DQ and DM input setup time relative to DQS
    parameter TDH               =        175; // tDH      ps  DQ and DM input hold time relative to DQS
    parameter TIS               =        175; // tIS      ps  Input Setup Time
    parameter TIH               =        175; // tIH      ps  Input Hold Time
    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay
`else `ifdef sg167
    parameter TCK_MIN           =       1670; // tCK      ps  Minimum Clock Cycle Time
    parameter TDQSQ             =        200; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TDS               =        175; // tDS      ps  DQ and DM input setup time relative to DQS
    parameter TDH               =        175; // tDH      ps  DQ and DM input hold time relative to DQS
    parameter TIS               =        175; // tIS      ps  Input Setup Time
    parameter TIH               =        175; // tIH      ps  Input Hold Time
    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay
`else `ifdef sg187
    parameter TCK_MIN           =       1875; // tCK      ps  Minimum Clock Cycle Time
    parameter TDQSQ             =        200; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TDS               =        175; // tDS      ps  DQ and DM input setup time relative to DQS
    parameter TDH               =        175; // tDH      ps  DQ and DM input hold time relative to DQS
    parameter TIS               =        175; // tIS      ps  Input Setup Time
    parameter TIH               =        175; // tIH      ps  Input Hold Time
    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay
`else `ifdef sg215
    parameter TCK_MIN           =       2150; // tCK      ps  Minimum Clock Cycle Time
    parameter TDQSQ             =        200; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TDS               =        175; // tDS      ps  DQ and DM input setup time relative to DQS
    parameter TDH               =        175; // tDH      ps  DQ and DM input hold time relative to DQS
    parameter TIS               =        175; // tIS      ps  Input Setup Time
    parameter TIH               =        175; // tIH      ps  Input Hold Time
    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay
`else `ifdef sg25
    parameter TCK_MIN           =       2500; // tCK      ps  Minimum Clock Cycle Time
    parameter TDQSQ             =        200; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TDS               =        175; // tDS      ps  DQ and DM input setup time relative to DQS
    parameter TDH               =        175; // tDH      ps  DQ and DM input hold time relative to DQS
    parameter TIS               =        175; // tIS      ps  Input Setup Time
    parameter TIH               =        175; // tIH      ps  Input Hold Time
    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay
`else `ifdef sg6
    parameter TCK_MIN           =       6000; // tCK      ps  Minimum Clock Cycle Time
    parameter TDQSQ             =        200; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TDS               =        175; // tDS      ps  DQ and DM input setup time relative to DQS
    parameter TDH               =        175; // tDH      ps  DQ and DM input hold time relative to DQS
    parameter TIS               =        175; // tIS      ps  Input Setup Time
    parameter TIH               =        175; // tIH      ps  Input Hold Time
    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay
`endif `endif `endif `endif `endif `endif `endif `endif `endif `endif `endif
   
    // Timing Parameters

    // Clock
    parameter CKH_MIN          =    0.45; // tCH    tCK   Minimum Clock High-Level Pulse Width
    parameter CKH_MAX          =    0.55; // tCH    tCK   Maximum Clock High-Level Pulse Width
    parameter CKL_MIN          =    0.45; // tCL    tCK   Minimum Clock Low-Level Pulse Width
    parameter CKL_MAX          =    0.55; // tCL    tCK   Maximum Clock Low-Level Pulse Width
    // Read
    parameter TDQSCK           =    3000; // tDQSCK ps    DQS output access time from CK/CK#
//    parameter TDQSCK           =    3700; // tDQSCK ps    DQS output access time from CK/CK#
    parameter TDQSCK_MIN       =    2500; // tDQSCK ps    DQS output access time from CK/CK#
    parameter TDQSCK_MAX       =    5500; // tDQSCK ps    DQS output access time from CK/CK#
    // Write
    parameter DQSH             =    0.40; // tDQSH  tCK   DQS input High Pulse Width
    parameter DQSL             =    0.40; // tDQSL  tCK   DQS input Low Pulse Width
    parameter DQSS             =    0.75; // tDQSS  tCK   Rising clock edge to DQS/DQS# latching transition
    parameter DSS              =    0.20; // tDSS   tCK   DQS falling edge to CLK rising (setup time)
    parameter DSH              =    0.20; // tDSH   tCK   DQS falling edge from CLK rising (hold time)
    parameter WPRE             =    0.35; // tWPRE  tCK   DQS Write Preamble
    parameter WPST             =    0.40; // tWPST  tCK   DQS Write Postamble
    // CKE
    parameter CKE              =       3; // tCKE   tCK   CKE minimum high or low pulse width
    parameter TCKESR           =   15000; // tCKESR ps    CKE minimum high or low pulse width self refresh
    parameter ISCKE            =    0.25; // tISCKE tCK   CKE Input Setup Time
    parameter IHCKE            =    0.25; // tIHCKE tCK   CKE Input Hold Time
    // Mode Register
    parameter MRR              =       4; // tMRR   tCK   Load Mode Register command cycle time
    parameter MRW              =       4; // tMRW   tCK   Load Mode Register command cycle time
    parameter CL_MIN           =       3; // CL     tCK   Minimum CAS Latency
    parameter CL_MAX           =      12; // CL     tCK   Maximum CAS Latency
    parameter TCL              =   15000; // CL     ps    Minimum CAS Latency
    parameter WR_MIN           =       3; // WR     tCK   Minimum Write Recovery
    parameter WR_MAX           =      16; // WR     tCK   Maximum Write Recovery
    parameter BL_MIN           =       8; // BL     tCK   Minimum Burst Length
`ifndef LPDDR3ECB
    parameter BL_MAX           =      16; // BL     tCK   Minimum Burst Length
    parameter MR8RESID         =      2'b11;
`else                                                                            //ECBREMOVE
    parameter BL_MAX           =      32; // BL     tCK   Minimum Burst Length   //ECBREMOVE
    parameter MR8RESID         =      2'b11;                                     //ECBREMOVE
`endif
    parameter DLLK             =     200; // tDLLK  tCK   DLL locking time
    // Command and Address
    // parameter CCD              =       2; // tCCD   tCK   Cas to Cas command delay // MYY not used, use SX instead
    parameter TFAW             =   50000; // tFAW   ps    Four access window time for the number of activates in an 8 bank device
    parameter FAW              =       8; // tFAW   tCK   Four access window time for the number of activates in an 8 bank device // MYY change to 8
    parameter TRAS             =   42000; // tRAS   ps    Minimum Active to Precharge command time
    parameter RAS              =       3; // tRAS   tCK   Minimum Active to Precharge command time  // MYY chagne to 3
`ifdef LPDDR3_FAST
    parameter TRCD             =   15000; // tRCD   ps    Active to Read/Write command time
`elsif LPDDR3_TYP
    parameter TRCD             =   18000; // tRCD   ps    Active to Read/Write command time
`elsif LPDDR3_SLOW
    parameter TRCD             =   24000; // tRCD   ps    Active to Read/Write command time
`endif
    parameter RCD              =       3; // tRCD   tCK   Active to Read/Write command time
`ifdef LPDDR3_FAST
    parameter RPAB             =      3;
`else
    parameter RPAB             =      4;
`endif
`ifdef LPDDR3_FAST
    parameter TRPPB            =   15000; // tRPpb  ps    Precharge command period
`elsif LPDDR3_TYP
    parameter TRPPB            =   18000; // tRPpb  ps    Precharge command period
`elsif LPDDR3_SLOW
    parameter TRPPB            =   24000; // tRPpb  ps    Precharge command period
`endif
    parameter TRPAB             =      TRPPB + 3000;
    parameter RPPB             =       3; // tRPpb  tCK   Precharge command period
    parameter TRRD             =   10000; // tRRD   ps    Active bank a to Active bank b command time
    parameter RRD              =       2; // tRRD   tCK   Active bank a to Active bank b command time
    parameter TRTP             =    7500; // tRTP   ps    Read to Precharge command delay
    parameter RTP              =       4; // tRTP   tCK   Read to Precharge command delay
    parameter TWR              =   13125; // tWR    ps    Write recovery time
    parameter WR               =       3; // tWR    tCK   Write recovery time
    parameter WTR              =       4; // tWTR   tCK   Write to Read command delay
    parameter TXP              =    7500; // tXP    ps    Exit power down to first valid command
    parameter XP               =       2; // tXP    tCK   Exit power down to first valid command
    parameter XSR              =       2; // tXSR     tCK Exit self refesh to first valid command
    // Refresh
    parameter TRFCPB           =   60000; // tRFCpb ps    Refresh to Refresh Command interval minimum value
`ifdef lpddr3_8Gb
    parameter TRFCAB           =  210000; // tRFCab ps    Refresh to Refresh Command interval minimum value
`elsif lpddr3_4Gb
    parameter TRFCAB           =  130000; // tRFCab ps    Refresh to Refresh Command interval minimum value
`else
    parameter TRFCAB           =  130000; // tRFCab ps    Refresh to Refresh Command interval minimum value
`endif
    parameter TXSR             =      TRFCAB + 10000;
`ifdef lpddr3_8Gb
    parameter TREFBW           =  6720000; // tREFBW   ps  Burst Refresh Window
`elsif lpddr3_4Gb
    parameter TREFBW           =  4160000; // tREFBW   ps  Burst Refresh Window
`else
    parameter TREFBW           =  4160000; // tREFBW   ps  Burst Refresh Window
`endif
   
    // Initialization
    parameter TINIT1           =  100000; // tINIT1 ps
    parameter INIT2            =       5; // tINIT2 tCK
    parameter TINIT3          =200000000; // tINIT3 ps
    parameter TINIT4           =  281000; // tINIT3 ps
    parameter TINIT5           =10000000; // tINIT3 ps
    parameter TZQINIT          = 1000000; // tZQINIT  ps  Calibration Initialization Time
    parameter TZQCL            =  360000; // tZQCL    ps  Long (Full) Calibration Time
    parameter TZQCS            =   90000; // tZQCS    ps  Short Calibration Time
    parameter TZQRESET         =   50000; // tZQRESET ps  Calibration Reset Time

    // CA Train
    parameter TCAMRD           =  20;
    parameter TCACKEL          =  10;
    parameter TCACKEH          =  10;
    parameter TCAENT           =  10;
    parameter TCAEXT           =  10;
    parameter TADR             = 20000;
    parameter TMRZ             = 3000;
    parameter TWLDQSEN = 25000;
    parameter TWLMRD = 40000;
    parameter TWLO = 10000;


    // Size Parameters based on Part Width
`ifdef x16
`ifdef BANKS_8
    parameter ROW_BITS         =      14; // Set this parameter to control how many Address bits are used
`else
    parameter ROW_BITS         =      15; // Set this parameter to control how many Address bits are used
`endif
`ifdef HALF_DENSITY
    parameter COL_BITS         =      10; // Set this parameter to control how many Column bits are used
`else
    parameter COL_BITS         =      11; // Set this parameter to control how many Column bits are used
`endif
    parameter DM_BITS          =       2; // Set this parameter to control how many Data Mask bits are used
    parameter DQ_BITS          =      16; // Set this parameter to control how many Data bits are used       **Same as part bit width**
    parameter DQS_BITS         =       2; // Set this parameter to control how many Dqs bits are used
`else `define x32
`ifdef BANKS_8
    parameter ROW_BITS         =      14; // Set this parameter to control how many Address bits are used
`else
    parameter ROW_BITS         =      15; // Set this parameter to control how many Address bits are used
`endif
`ifdef HALF_DENSITY
    parameter COL_BITS         =       9; // Set this parameter to control how many Column bits are used
`else
    parameter COL_BITS         =      10; // Set this parameter to control how many Column bits are used
`endif
    parameter DM_BITS          =       4; // Set this parameter to control how many Data Mask bits are used
    parameter DQ_BITS          =      32; // Set this parameter to control how many Data bits are used       **Same as part bit width**
    parameter DQS_BITS         =       4; // Set this parameter to control how many Dqs bits are used
`endif
   
    // Size Parameters
    parameter BA_BITS          =       3; // Set this parmaeter to control how many Bank Address bits are used
    parameter CA_BITS          =      10; // Command Address Bits
    parameter MEM_BITS         =      20; // Set this parameter to control how many write data bursts can be stored in memory.  The default is 2^10=1024.
    parameter SX               =       8; // prefetch architecture. 
   
    // Simulation parameters
parameter BUS_DELAY        =       0; // delay in picoseconds
    parameter STOP_ON_ERROR    =       0; // If set to 1, the model will halt on command sequence/major errors
    parameter DEBUG            =       0; // Turn on debug messages
    parameter MSGLENGTH        =     256; // max length in characters of a debug string
   
