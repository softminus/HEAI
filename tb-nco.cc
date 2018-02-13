#include "Vnco.h"
#include "verilated.h"
#include "verilated_vcd_c.h"


int main(int argc, char **argv, char **env) {
  int i;
  int clk;
  Verilated::commandArgs(argc, argv);
  // init top verilog instance
  Vnco* top = new Vnco;
  // init trace dump
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  top->trace (tfp, 99);
  tfp->open ("nco.vcd");
  // initialize simulation inputs
  top->clock = 1;
  top->clk_en = 0;
  top->phase_increment = 1;
  // run simulation for 1000 clock periods
  for (i=0; i<1000; i++) {
    // dump variables into VCD file and toggle clock
    for (clk=0; clk<2; clk++) {
      tfp->dump (2*i+clk);
      top->clock = !top->clock;
      top->eval ();
    }
    top->clk_en = (i > 5);
    if (Verilated::gotFinish())  exit(0);
  }
  tfp->close();
  exit(0);
}
