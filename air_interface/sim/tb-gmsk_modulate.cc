#include "Vgmsk_modulate.h"
#include "verilated.h"
#include "verilated_vcd_c.h"


#include <stdint.h>
#include <math.h>

int main(int argc, char **argv, char **env) {
    srand(time(0));
    int tick_count;
    int clk;
    int8_t i,q;
    Verilated::commandArgs(argc, argv);
    // init gmsk_modulate verilog instance
    Vgmsk_modulate* gmsk_modulate = new Vgmsk_modulate;
    // init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    gmsk_modulate->trace (tfp, 99);
    tfp->open ("gmsk_modulate.vcd");
    // initialize simulation inputs
    gmsk_modulate->clock = 0;
    // run simulation for 1000 crystal periods
    for (tick_count=1; tick_count<131072; tick_count++) {
//            gmsk_modulate->rf_in_i = (sin(2*i/100.0) * 128.0);
//            gmsk_modulate->rf_in_q = (cos(2*i/100.0) * 128.0);
//            gmsk_modulate->lo_in_i = (sin(2.5*i/100.0) * 128.0);
//            gmsk_modulate->lo_in_q = -(cos(2.5* i/100.0) * 128.0);

        gmsk_modulate->clock = 0;
        gmsk_modulate->eval ();
        tfp->dump (10*tick_count-2);

        gmsk_modulate->clock = 1;
        gmsk_modulate->eval ();
        tfp->dump (10*tick_count);

        if ((tick_count)%(31*4)==0) {
            gmsk_modulate->current_symbol = (rand())%2;
        }

        gmsk_modulate->clock = 0;
        gmsk_modulate->eval ();
        tfp->dump (10*tick_count+5);
        tfp->flush();

        i = gmsk_modulate->inphase_out;
        q = gmsk_modulate->quadrature_out;

        printf("%d %d %d\n", tick_count, i,q);
        if (Verilated::gotFinish())    exit(0);
    }
    tfp->close();
    exit(0);
}
