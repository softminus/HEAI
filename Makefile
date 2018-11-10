# Project setup
PROJ      = gmsk_tx
BUILD     = ./build

DEVICE    		= 8k
ICETIME_DEVICE	= hx8k

FOOTPRINT = ct256

# Files
LINTABLE_FILES = air_interface/rtl/gmsk_tx.v air_interface/rtl/tx_burst.v
FILES = $(LINTABLE_FILES) top.v icepll.v 
PCF = pinmap.pcf



BIN_FILE 	= $(BUILD)/$(PROJ).bin
ASC_FILE 	= $(BUILD)/$(PROJ).asc
JSON_FILE 	= $(BUILD)/$(PROJ).json

all: $(BIN_FILE)

$(JSON_FILE): $(FILES)
	yosys -p "synth_ice40 -top top -json $(JSON_FILE)" $^

$(ASC_FILE): $(JSON_FILE) $(PCF)
	nextpnr-ice40 --$(ICETIME_DEVICE) --json $(JSON_FILE) --pcf $(PCF) --asc $(ASC_FILE)

$(BIN_FILE): $(ASC_FILE)
	icepack $< $@

burn: $(BIN_FILE)
	iceprog $<

sram: $(BIN_FILE)
	iceprog -S $<

timing: $(ASC_FILE)
	icetime -tmd $(ICETIME_DEVICE) $<

lint: $(LINTABLE_FILES)
	verilator -Wall --lint-only top.v $^

sim:
	verilator -Wall --cc --trace air_interface/rtl/gmsk_tx.v --exe air_interface/sim/tb-gmsk_tx.cc
	make -j -C obj_dir/ -f Vgmsk_tx.mk Vgmsk_tx
	./obj_dir/Vgmsk_tx > verilog_out.txt
	# -gtkwave top.vcd top.sav

clean:
	rm -rf build/* obj_dir top.vcd verilog_out.txt gmsk_tx.vcd
