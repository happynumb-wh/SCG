COMPILE_TOOL    	:= vcs
RTL_DIR 			= $(PWD)/rtl

COMPILE_OPTIONS 	:= -l ./logs/compile.log \
					-q -Mdir=./output/csrc \
					-CFLAGS -DVCS \
					-lca -kdb \
					-full64 +v2k -sverilog \
					-timescale=1ns/1ps \
					-diag timescale \
					+notimingcheck\
					+nospecify \
					+lint=TFIPC-L \
					-diag=sdf:verbose \
					-LDFLAGS -Wl,--no-as-needed\
					-o ./output/simvcssvlog \
					+plusarg_save -debug_access+pp+dmptf+thread \
					-debug_region=cell+encrypt -notice \
					+define+RANDOMIZE_REG_INIT  \
					-P ${NOVAS_PLI}/novas.tab ${NOVAS_PLI}/pli.a \
					-cm line+cond+fsm+tgl \
					-cm_hier ddr_sys.cfg \
					-cm_name simv \
					-cm_dir  ./cov	



# SCG target
SCG_FILES 			:= -f $(RTL_DIR)/mc_filelist.f \
						$(RTL_DIR)/SCG_V2.sv

# DRAM
DRAM_DIR 			:= $(RTL_DIR)/src/testbench/models/memory_models/micron/ddr4/ddr4_modified
DRAM_FILES 			:= +incdir+$(DRAM_DIR)\
					 +incdir+$(RTL_DIR)/src/testbench \
					 $(RTL_DIR)/src/testbench/DWC_DDRPHY_define.v \
					 $(DRAM_DIR)/arch_defines.v \
					 $(DRAM_DIR)/arch_package.sv \
					 $(DRAM_DIR)/proj_package.sv \
					 $(DRAM_DIR)/interface.sv \
					 $(DRAM_DIR)/StateTable.sv \
					 $(DRAM_DIR)/MemoryArray.sv \
					 $(DRAM_DIR)/ddr4_model.sv \
					 $(DRAM_DIR)/ddr4_model_top.v

TOP_FILES 			:= $(RTL_DIR)/top.sv \
					   +incdir+$(RTL_DIR)/src

DEFINE_OPTIONS 		:= +define+UVM_PACKER_MAX_BYTES=1500000 \
                  +define+UVM_DISABLE_AUTO_ITEM_RECORDING \
                  +define+SVT_FSDB_ENABLE \
                  +define+WAVES_FSDB \
                  +define+WAVES="fsdb" \
                  +define+SVT_UVM_TECHNOLOGY \
                  +define+SYNOPSYS_SV \
                  +define+DDR4_16G_X8 \
                  +define+DQ64 \
                  +define+DDR4_2400 \
                  +define+SEED=10639954 \
                  +define+DQ=64 \
                  +define+MICRON_DDR \
                  +define+DDR4_16Gbx8 \
                  +define+DDR4 \
                  +define+SRAM_SIM \
                  +define+DDR4_2400

VCS_VFLAG			:= -kdb \
					-diag timescale \
					+notimingcheck\
					+nospecify \
					+lint=TFIPC-L \
					-diag=sdf:verbose \
					+plusarg_save -debug_access+pp+dmptf+thread \
					-debug_region=cell+encrypt -notice \
					+define+RANDOMIZE_REG_INIT  \
					-cm line+cond+fsm+tgl \
					-cm_hier ddr_sys.cfg \
					-cm_name simv \
					-cm_dir  ./cov \
				    -f $(RTL_DIR)/mc_filelist.f


compile:
	mkdir -p logs; mkdir -p output; \
	vcs $(COMPILE_OPTIONS) $(DEFINE_OPTIONS) -f $(RTL_DIR)/mc_filelist.f