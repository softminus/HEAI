# Project setup
PROJ      = xpdr
BUILD     = ./build
DEVICE    = 8k
FOOTPRINT = ct256

# Files
FILES = top.v lms6_tx.v clock.v nco.v

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
	verilator -Wall --lint-only $(FILES)


clean:
	rm build/*
