#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"


#include <stdint.h>
#include <math.h>

int main(int argc, char **argv, char **env) {
    srand(time(0));
    int tick_count;
    int clk;
    int16_t i,q;
    Verilated::commandArgs(argc, argv);
    // init top verilog instance
    Vtop* top = new Vtop;
    // init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("top.vcd");
    // initialize simulation inputs
    top->xtal = 0;
    // run simulation for 1000 crystal periods
    for (tick_count=1; tick_count<131072; tick_count++) {
//            top->rf_in_i = (sin(2*i/100.0) * 128.0);
//            top->rf_in_q = (cos(2*i/100.0) * 128.0);
//            top->lo_in_i = (sin(2.5*i/100.0) * 128.0);
//            top->lo_in_q = -(cos(2.5* i/100.0) * 128.0);

        top->xtal = 0;
        top->eval ();
        tfp->dump (10*tick_count-2);

        top->xtal = 1;
        top->eval ();
        tfp->dump (10*tick_count);



        top->xtal = 0;
        top->eval ();
        tfp->dump (10*tick_count+5);
        tfp->flush();

        i = top->a_x;
        q = top->b_x;

        printf("%d %d %d\n", tick_count, i,q);
        if (Verilated::gotFinish())    exit(0);
    }
    tfp->close();
    exit(0);
}
