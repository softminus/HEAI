# Project setup
PROJ      = xpdr
BUILD     = ./build
DEVICE    = 8k
FOOTPRINT = ct256

# Files
LINTABLE_FILES = nco.v lms6_tx.v
FILES = $(LINTABLE_FILES) top.v icepll.v 
.PHONY: all clean burn

all:
	# if build folder doesn't exist, create it
	mkdir -p $(BUILD)
	./qwave_romgen.py > qwave_6i_4o.hex
	# synthesize using Yosys
	yosys -p "synth_ice40 -top top -blif $(BUILD)/$(PROJ).blif" $(FILES)
	# Place and route using arachne
	arachne-pnr -d $(DEVICE) -P $(FOOTPRINT) -o $(BUILD)/$(PROJ).asc -p pinmap.pcf $(BUILD)/$(PROJ).blif
	# Convert to bitstream using IcePack
	icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin

burn:
	iceprog $(BUILD)/$(PROJ).bin

lint:
	verilator -Wall --lint-only nco.v
	verilator -Wall --lint-only lms6_tx.v

sim:
	verilator -Wall --cc --trace nco.v --exe tb-nco.cc
	make -j -C obj_dir/ -f Vnco.mk Vnco
	obj_dir/Vnco
	-gtkwave nco.vcd nco.sav

clean:
	rm -rf build obj_dir nco.vcd
