#include "Vgmsk_tx.h"
#include "verilated.h"
#include "verilated_vcd_c.h"


#include <stdint.h>
#include <math.h>

int main(int argc, char **argv, char **env) {
    int tick_count;
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
    gmsk_tx->clock = 0;
    // run simulation for 1000 crystal periods
    for (tick_count=1; tick_count<1000; tick_count++) {
//            gmsk_tx->rf_in_i = (sin(2*i/100.0) * 128.0);
//            gmsk_tx->rf_in_q = (cos(2*i/100.0) * 128.0);
//            gmsk_tx->lo_in_i = (sin(2.5*i/100.0) * 128.0);
//            gmsk_tx->lo_in_q = -(cos(2.5* i/100.0) * 128.0);

        gmsk_tx->clock = 0;
        gmsk_tx->eval ();
        tfp->dump (10*tick_count-2);

        gmsk_tx->clock = 1;
        gmsk_tx->eval ();
        tfp->dump (10*tick_count);

        if (tick_count%2==0) {
            gmsk_tx->sample_strobe = 1;
        } else {
            gmsk_tx->sample_strobe = 0;
        }

        if (tick_count%17==0) {
            //gmsk_tx->symbol_strobe = 1;
        } else {
            //gmsk_tx->symbol_strobe = 0;
        }


        gmsk_tx->clock = 0;
        gmsk_tx->eval ();
        tfp->dump (10*tick_count+5);
        tfp->flush();

        printf("%d %d\n", tick_count, gmsk_tx->inphase_out);
        if (Verilated::gotFinish())    exit(0);
    }
    tfp->close();
    exit(0);
}
