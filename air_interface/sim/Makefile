sim:
	verilator -Wall --cc --trace gmsk_tx.v --exe tb-gmsk_tx.cc
	make -j -C obj_dir/ -f Vgmsk_tx.mk Vgmsk_tx
	./obj_dir/Vgmsk_tx
	./obj_dir/Vgmsk_tx > verilog_out.txt
	# -gtkwave top.vcd top.sav

clean:
	rm -rf build/* obj_dir verilog_out.txt gmsk_tx.vcd

