#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"


#include <stdint.h>
#include <math.h>

int main(int argc, char **argv, char **env) {
  int i;
  int clk;
  Verilated::commandArgs(argc, argv);
  // init top verilog instance
  Vtop* top = new Vtop;
  // init trace dump
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  top->trace (tfp, 99);
  tfp->open ("top.vcd");
  // initialize simulation inputs
  top->crystal = 1;
  // run simulation for 1000 crystal periods
  for (i=0; i<1000; i++) {
      top->rf_in_i = (sin(2*i/100.0) * 128.0);
      top->rf_in_q = (cos(2*i/100.0) * 128.0);
      top->lo_in_i = -(sin(2.5*i/100.0) * 128.0);
      top->lo_in_q = (cos(2.5* i/100.0) * 128.0);

    // dump variables into VCD file and toggle crystal
    for (clk=0; clk<2; clk++) {
      tfp->dump (2*i+clk);
      top->crystal = !top->crystal;
      printf("iter = %d, out_i=%d, out_q=%d\n", 2*i+clk, top->out_i, top->out_q);
      top->eval ();
    }
    if (Verilated::gotFinish())  exit(0);
  }
  tfp->close();
  exit(0);
}
