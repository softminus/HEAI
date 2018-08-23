#include "Vgmsk_tx.h"
#include "verilated.h"
#include "verilated_vcd_c.h"


#include <stdint.h>
#include <math.h>

int main(int argc, char **argv, char **env) {
int i;
    int clk;
    Verilated::commandArgs(argc, argv);
    // init gmsk_tx verilog instance
    Vgmsk_tx* gmsk_tx = new Vgmsk_tx;
    // init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    gmsk_tx->trace (tfp, 99);
    tfp->open ("gmsk_tx.vcd");
    // initialize simulation inputs
    gmsk_tx->clock = 1;
    // run simulation for 1000 crystal periods
    for (i=0; i<1000; i++) {
//            gmsk_tx->rf_in_i = (sin(2*i/100.0) * 128.0);
//            gmsk_tx->rf_in_q = (cos(2*i/100.0) * 128.0);
//            gmsk_tx->lo_in_i = (sin(2.5*i/100.0) * 128.0);
//            gmsk_tx->lo_in_q = -(cos(2.5* i/100.0) * 128.0);


        // dump variables into VCD file and toggle crystal
        for (clk=0; clk<2; clk++) {
            tfp->dump (2*i+clk);
            gmsk_tx->clock = !gmsk_tx->clock;
            if(i == 30 && clk ==1) {
                gmsk_tx->symbol_strobe = 1;
            } else if (i == 31 && clk==0) {
                gmsk_tx->symbol_strobe=0;
            }
            printf("%d %d\n", 2*i+clk, gmsk_tx->inphase_out);
            gmsk_tx->eval ();
        }
        if (Verilated::gotFinish())    exit(0);
    }
    tfp->close();
    exit(0);
}
