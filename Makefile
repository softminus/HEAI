# Project setup
PROJ      = gmsk_phy
BUILD     = ./build

DEVICE    		= 8k
ICETIME_DEVICE	= hx8k

FOOTPRINT = ct256

# Files
LINTABLE_FILES = air_interface/rtl/gmsk_modulate.v air_interface/rtl/tx_burst.v air_interface/rtl/multirate_strobe.v
FILES = $(LINTABLE_FILES) top.v icepll.v 
PCF = pinmap.pcf



BIN_FILE 	= $(BUILD)/$(PROJ).bin
ASC_FILE 	= $(BUILD)/$(PROJ).asc
JSON_FILE 	= $(BUILD)/$(PROJ).json

all: $(BIN_FILE)

$(JSON_FILE): $(FILES)
	yosys -p "synth_ice40 -top top -abc2 -relut -json $(JSON_FILE)" $^

$(ASC_FILE): $(JSON_FILE) $(PCF)
	nextpnr-ice40 --$(ICETIME_DEVICE) --json $(JSON_FILE) --pcf $(PCF) --asc $(ASC_FILE) --freq 80 --opt-timing

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

mod_sim:
	verilator -Wall --cc --trace air_interface/rtl/gmsk_modulate.v --exe air_interface/sim/tb-gmsk_modulate.cc
	make -j -C obj_dir/ -f Vgmsk_modulate.mk Vgmsk_modulate
	./obj_dir/Vgmsk_modulate > verilog_out.txt
	# -gtkwave top.vcd top.sav

burst_sim:
	python3 air_interface/gen/gmsk_phasetables.py air_interface/gen/
	verilator -Wall --cc --trace top.v air_interface/rtl/tx_burst.v air_interface/rtl/gmsk_modulate.v air_interface/rtl/multirate_strobe.v --exe air_interface/sim/tb-tx_burst.cc
	make -j -C obj_dir/ -f Vtop.mk Vtop
	./obj_dir/Vtop > verilog_out.txt


clean:
	rm -rf build/* obj_dir top.vcd verilog_out.txt gmsk_modulate.vcd nco.vcd gmsk_tx.vcd tx_burst.vcd

