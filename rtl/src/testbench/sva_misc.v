/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Modules containing miscellaneous task for sva                 *
 *                                                                            *
 *****************************************************************************/

`ifdef SVA

// assertion error messages
// ------------------------
// logs the error and prints a message
task assertion_err_msg;
    input [8*100:1] msg;
    begin
      $write("-> %0t: ", $realtime);
      $write("[ASSERT] ASSERTION ERROR: %0s\n",msg);
      `SYS.error;
    end 
endtask

task assertion_msg;
    input [8*60:1] msg;
    begin
      $write("-> %0t: ", $realtime);
      $write("[ASSERT] %0s\n",msg);    
    end
endtask // assertion_msg

task err_msg;
    input [8*60:1] msg;
    begin
      $write("-> %0t: ", $realtime);
      $write("ERROR: %0s\n",msg);
      `SYS.error;
    end 
endtask

task assertion_err_msg_on_rank;
    input integer  rank_no;
    input [8*60:1] msg;
    
    begin
      $write("-> %0t: ", $realtime);
      $write("[ASSERT] ASSERTION ERROR AT RANK %0d:  %0s\n", rank_no, msg);
      `SYS.error;
    end 
endtask

task assertion_msg_on_rank;
    input integer  rank_no;
    input [8*60:1] msg;
    begin
      $write("-> %0t: ", $realtime);
      $write("[ASSERT] AT RANK %0d:  %0s\n", rank_no, msg);    
    end
endtask // assertion_msg


task err_msg_on_rank;
    input integer  rank_no;
    input [8*60:1] msg;
    begin
      $write("-> %0t: ", $realtime);
      $write("ERROR AT RANK %0d:  %0s\n", rank_no, msg);
      `SYS.error;
    end 
    
endtask

`endif
