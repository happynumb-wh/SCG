include compile.mk
PWD 			= $(shell pwd)
SRC_DIR 		= $(PWD)/src
AXI2UI_DIR 		= $(SRC_DIR)/scg
RTL_DIR 		= $(PWD)/rtl
WAIVER_DIR 		= $(PWD)/src
TRACE_DIR 		= $(PWD)/test/data
TRACE_FILE 		= $(TRACE_DIR)/cactusADM_0_rand100w.txt
INTERNAL_FILE 	= $(PWD)/internal.yaml
TOP_MODULE 		= scg_top
PYTEST_THREADS = 4
PICKER_VFLAG		= $(VCS_VFLAG) $(DEFINE_OPTIONS)

.PHONY:all init test

all: test

init-verilator:
	picker export --autobuild=false $(RTL_DIR)/$(TOP_MODULE).sv -w $(PWD)/$(TOP_MODULE).fst --sname $(TOP_MODULE) --tdir $(AXI2UI_DIR) --lang python -e -c --sim verilator --internal $(INTERNAL_FILE)
	$(MAKE) -C $(AXI2UI_DIR)

init-vcs:
	picker export --autobuild=false $(RTL_DIR)/top.sv -V "\"$(PICKER_VFLAG)\"" -w $(PWD)/$(TOP_MODULE).fsdb --sname $(TOP_MODULE) --tdir $(AXI2UI_DIR) --lang python -e -c --sim vcs --internal $(INTERNAL_FILE)
# $(MAKE) -C $(AXI2UI_DIR)

test:
	LD_PRELOAD=$(LD_PRELOAD):$(AXI2UI_DIR)/_UT_$(TOP_MODULE).so python3 $(SRC_DIR)/main.py

run:
	pytest --toffee-report -sv $(SRC_DIR) -n$(PYTEST_THREADS)

clean:
	rm -rf $(AXI2UI_DIR)


