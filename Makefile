# Project setup
PROJ      = xpdr
BUILD     = ./build

DEVICE    		= 8k
ICETIME_DEVICE	= hx8k

FOOTPRINT = ct256

# Files
LINTABLE_FILES = nco.v lms6_tx.v complex_mixer.v
FILES = $(LINTABLE_FILES) top.v icepll.v 
PCF = pinmap.pcf



BIN_FILE 	= $(BUILD)/$(PROJ).bin
ASC_FILE 	= $(BUILD)/$(PROJ).asc
BLIF_FILE 	= $(BUILD)/$(PROJ).blif

all: $(BIN_FILE)

$(BLIF_FILE): $(FILES)
	./qwave_romgen.py > qwave_6i_4o.hex
	yosys -p "synth_ice40 -top top -blif $(BLIF_FILE)" $^

$(ASC_FILE): $(BLIF_FILE) $(PCF)
	arachne-pnr -d $(DEVICE) -P $(FOOTPRINT) -o $(ASC_FILE) -p $(PCF) $<

$(BIN_FILE): $(ASC_FILE)
	icepack $< $@

burn: $(BIN_FILE)
	iceprog $<

sram: $(BIN_FILE)
	iceprog -S $<

timing: $(ASC_FILE)
	icetime -tmd $(ICETIME_DEVICE) $<

lint: $(LINTABLE_FILES)
	verilator -Wall --lint-only top.v

sim:
	verilator -Wall --cc --trace top.v --exe tb-top.cc
	make -j -C obj_dir/ -f Vtop.mk Vtop
	obj_dir/Vtop
	# -gtkwave top.vcd top.sav

clean:
	rm -rf build/* obj_dir top.vcd

