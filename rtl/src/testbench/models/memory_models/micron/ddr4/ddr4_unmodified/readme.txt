Disclaimer of Warranty:
-----------------------
This software code and all associated documentation, comments or other 
information (collectively "Software") is provided "AS IS" without 
warranty of any kind. MICRON TECHNOLOGY, INC. ("MTI") EXPRESSLY 
DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
TO, NONINFRINGEMENT OF THIRD PARTY RIGHTS, AND ANY IMPLIED WARRANTIES 
OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. MTI DOES NOT 
WARRANT THAT THE SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE 
OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. 
FURTHERMORE, MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR 
THE RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS, 
ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT OF USE 
OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO EVENT SHALL MTI, 
ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE LIABLE FOR ANY DIRECT, 
INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR SPECIAL DAMAGES (INCLUDING, 
WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, BUSINESS INTERRUPTION, 
OR LOSS OF INFORMATION) ARISING OUT OF YOUR USE OF OR INABILITY TO USE 
THE SOFTWARE, EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
DAMAGES. Because some jurisdictions prohibit the exclusion or 
limitation of liability for consequential or incidental damages, the 
above limitation may not apply to you.

Copyright 2011 Micron Technology, Inc. All rights reserved.

Getting Started:
----------------
Unzip the included files to a folder.
Compile and run using 'run' scripts listed below.

File Descriptions:
------------------
readme.txt          // this file

----Project files----
arch_package.sv     // Defines parameters, enums and structures for DDR4.
arch_defines.v      // Defines chip sizes and widths.
ddr4_model.sv       // Defines ideal DDR4 dram behavior.
interface.sv        // Defines 'interface iDDR4'.
MemoryArray.sv      // Defines 'class MemoryArray'.
proj_package.sv     // Defines parameters, enums and structures for this
                    // specific DDR4.
StateTable.sv       // Wrapper around StateTableCore which creates 
                    // 'module StateTable'.
StateTableCore.sv   // Dram state core functionality.
timing_tasks.sv     // Defines enums and timing parameters for 
                    // available speed grades.

----Testbench----
tb.sv               // ddr4 model test bench.
subtest.vh          // Example test included by the test bench.

----Compile and run scripts----
run_modelsim        // Compiles and runs for modelsim (uses modelsim.do).
run_ncverilog       // Compiles and runs for ncverilog.
run_vcs             // Compiles and runs for vcs.
modelsim.do         // For use with modelsim.

Defining the Organization:
--------------------------
The verilog compiler directive "`define" may be used to choose between 
multiple organizations supported by the ddr4 model.
Valid organizations include: "X4", "X8", and "X16".
Valid sizes include: "2G", "4G", "8G", and "16G".
These two parameters are combined to define the organization tested. 
For example DDR4_4G_X8. Please see arch_defines.v for examples.
The following are examples of defining the organization.

    simulator   command line
    ---------   ------------
    ModelSim    vlog +define+DDR4_2G_X8 ddr4_model.sv [additional files]
    NC-Verilog  ncverilog +define+DDR4_2G_X8 ddr4_model.sv [additional files]
    VCS         vcs +define+DDR4_2G_X8 ddr4_model.sv [additional files]

All combinations of size and organization are considered valid 
by the ddr4 model even though a Micron part may not exist for every 
combination.

Use these +define parameters for debugging:
MODEL_DEBUG_MEMORY  // Prints messages for every read and write to the memory core.
MODEL_DEBUG_CMDS    // Prints messages for every command/clk on the dram bus.
