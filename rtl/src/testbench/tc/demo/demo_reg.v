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
// Register Write and Read Demo (demo_reg.v)
//-----------------------------------------------------------------------------
// This testcase demonstrates register write and read. All registers are first
// read, then written with random data, and then read again. The first read 
// returns register reset values.

module tc();

  //--------------------------------------------------------------------------//
  //   L o c a l    P a r a m e t e r s
  //--------------------------------------------------------------------------//

  //--------------------------------------------------------------------------//
  //   R e g i s t e r    a n d    W i r e    D e c l a r a t i o n s
  //--------------------------------------------------------------------------//

  integer i, j, dx_idx;
  reg [`REG_ADDR_WIDTH-1:0] reg_addr;
  reg [`REG_DATA_WIDTH-1:0] reg_data;

  //--------------------------------------------------------------------------//
  //   T e s t b e n c h    I n s t a n t i a t i o n
  //--------------------------------------------------------------------------//
  ddr_tb ddr_tb();
 
  //--------------------------------------------------------------------------//
  //   T e s t    S t i m u l u s
  //--------------------------------------------------------------------------// 

  initial
    begin
      // Workaround race condition with initial block from system.v
      #0;

      // disconnect all chips so they don't report warnings/errors as the
      // register bits change randomly
      `SYS.disconnect_all_sdrams;

      // initialization
      `SYS.phy_power_up;
      `SYS.train_for_loopback = 1'b0; // do not train for register test
      `CFG.reg_rnd_write_test = 1'b1; 

      // this testcase will set its own training
      `SYS.rdimm_auto_train_en    = 1'b0;
      
`ifdef DWC_DDRPHY_EMUL_XILINX
      `SYS.disconnect_all_sdrams;
      `GRM.update_cal_values_emul;
`else
      `SYS.skip_phy_power_up = 1'b1;
      `SYS.train_for_srd = 1'b0; // do not train for register test
      `SYS.power_up;
      `SYS.disconnect_all_sdrams;
`endif
      `SYS.disable_undefined_warning;
      `SYS.disable_all_rank_monitors;
      
      // this testcase read all register address space including revserved
      // addresses - so disable the warning for reserved adddresses
      `SYS.xpct_illegal = 1'b1;

      // Force the DFI to not respond to any VT drift which can change register values
      force `PUB.dfi_ctl_vt_drift = 1'b0;
      force `PUB.dfi_phy_vt_drift = 1'b0;

      // reset rankidr to allow read write to default rank 0
      `CFG.write_register(`RANKIDR, `RANKIDR_DEFAULT);
      
      for (j=0; j<3; j=j+1)
        begin
           
            for (i=`FIRST_REG_ADDR; i<=`LAST_REG_ADDR + 4; i=i+1)
              begin
                reg_addr = i;
                reg_data = {$random(`SYS.seed)};

                if(!((`GRM.lpddrx_mode==1) && j==0 && (i==`ACLCDLR))) begin
                  // avoid modifying sensitive register bits;
                  // also skip special registers
                  reg_addr = `SYS.skip_special_registers(reg_addr, `NEXT_ADDR);
                  reg_data = `SYS.skip_special_bits(reg_addr, reg_data);

                  case (j)
                    0: `CFG.read_register(reg_addr); // read reset values
                    1: begin
                       // Writing certain values to DXnGCR2 registers may cause bus conflict errors therefore always write default.
                       case (reg_addr)
                         `DX0GCR2,`DX1GCR2,`DX2GCR2,
                         `DX3GCR2, `DX4GCR2,`DX5GCR2,
                         `DX6GCR2,`DX7GCR2, `DX8GCR2: reg_data = `DXNGCR2_DEFAULT;
                       endcase // case (reg_addr)
                       
                       `CFG.write_register(reg_addr, reg_data);
                       end
                    2: `CFG.read_register(reg_addr);
                  endcase // case(j)
                end
              end
          `CFG.nops(10);
        end

       
      `END_SIMULATION;
      
    end // initial begin
  
endmodule // tc
