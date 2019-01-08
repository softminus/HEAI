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
    FILE *float_out;
    float i_float,q_float;
    Verilated::commandArgs(argc, argv);
    // init top verilog instance
    Vtop* top = new Vtop;
    // init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("top.vcd");
    float_out = fopen("verilog_out.bin", "w");
    // initialize simulation inputs
    top->xtal = 0;
    // run simulation for 1000 crystal periods
    for (tick_count=1; tick_count<65536; tick_count++) {
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

//        i = top->dac_zero;
//        q = top->dac_one;

        i = top->a_x;
        q = top->b_x;
        i_float = i - 255.0;
        q_float = q - 255.0;
        fwrite(&i_float, sizeof(i_float), 1, float_out);
        fwrite(&q_float, sizeof(q_float), 1, float_out);



        printf("%d %d %d\n", tick_count, i,q);
        if (Verilated::gotFinish())    exit(0);
    }
    tfp->close();
    fclose(float_out);
    exit(0);
}
