/*
* @File_name         : sram_dp_128x4.v
* @Author            : Shi-xian Yan
* @Create_time       : 2021-09-03 16:30:34
* @Last Modified by  : Shi-xian Yan
* @Last Modified time: 2021-09-03 17:20:02
* @Email             : yanshixian@ict.ac.com
* @Revision          : V1.0
*/
//   Memory Name:sadrls0s4LOW2p128x4m2b1w0c0p0d0t0s2z0rw00            
//   Memory Size:128 words x 4 bits                                   
//                                                                    
//                               PORT NAME                            
//                               ---------                            
//               Output Ports                                         
//                                   QB[3:0]                          
//               Input Ports:                                         
//                                   ADRA[6:0]                        
//                                   DA[3:0]                          
//                                   WEA                              
//                                   MEA                              
//                                   CLKA                             
//                                   TEST1A                           
//                                   RMEA                             
//                                   RMA[3:0]                         
//                                   ADRB[6:0]                        
//                                   MEB                              
//                                   CLKB                             
//                                   TEST1B                           
//                                   RMEB                             
//                                   RMB[3:0]                         

// -------------------------------------------------------------------- 
// This instance is generated with Periphery_Vt = LOW option.         
// -------------------------------------------------------------------- 
`timescale 1 ns / 1 ps 

module sram_dp_128x4( QB, ADRA, DA, WEA, MEA, CLKA, TEST1A, RMEA, RMA, ADRB, MEB, CLKB, TEST1B, RMEB, RMB);

output  [3:0] QB;
input  [6:0] ADRA;
input  [3:0] DA;
input WEA;
input MEA;
input CLKA;
input TEST1A;
input RMEA;
input  [3:0] RMA;
input  [6:0] ADRB;
input MEB;
input CLKB;
input TEST1B;
input RMEB;
input  [3:0] RMB;
sadrls0s4LOW2p128x4m2b1w0c0p0d0t0s2z0rw00 u_mem_sram_dp_128x4( .QB(QB), .ADRA(ADRA), .DA(DA), .WEA(WEA), .MEA(MEA), .CLKA(CLKA), .TEST1A(TEST1A), .RMEA(RMEA), .RMA(RMA), .ADRB(ADRB), .MEB(MEB), .CLKB(CLKB), .TEST1B(TEST1B), .RMEB(RMEB), .RMB(RMB));
endmodule