`timescale 1ps / 1fs

module vref_pda_checker();

parameter pNO_OF_DX_DQS=`DWC_DX_NO_OF_DQS ;
parameter pNUM_LANES=`DWC_DX_NO_OF_DQS * `DWC_NO_OF_BYTES;

generate
genvar bl_idx ;
for(bl_idx = 0; bl_idx < pNUM_LANES; bl_idx = bl_idx + 2)begin

always@(posedge `PUB.u_DWC_ddrphy_train.u_DWC_ddrphy_train_vref.ctl_clk or negedge `PUB.u_DWC_ddrphy_train.u_DWC_ddrphy_train_vref.ctl_rst_n)
 if ((pNO_OF_DX_DQS == 2) && `PUB.u_DWC_ddrphy_train.u_DWC_ddrphy_train_vref.x8mode) begin   //when in x8 mode using DATX4X2 PHY
   if((`PUB.u_DWC_ddrphy_train.u_DWC_ddrphy_train_vref.dram_mode ==1) && (`PUB.u_DWC_ddrphy_train.u_DWC_ddrphy_train_vref.vref_fsm == 5'h0e) && (`PHY.dq !== {4*pNUM_LANES{1'hz}} ||`PHY.dq !== {4*pNUM_LANES{1'hx}} ))begin
     if (~(|`PHY.dq[4*bl_idx+3 : 4*bl_idx])) begin
       if(|`PHY.dq[4*bl_idx+7 : 4*bl_idx+4])begin
         `SYS.error;
         $display("-> %0t: [assertion] ERROR: X8 mode in X4X2 PHY,using PDA mode during vref training,even nibble isn't 0 when odd nibble is 0 ", $time);
       end
     end
   end
 end

end

endgenerate

endmodule

    
