`default_nettype none
module icepll (input crystal, output pll_clock);

/* verilator lint_off DECLFILENAME */
SB_PLL40_CORE #(
    .PLLOUT_SELECT("GENCLK"),


.FEEDBACK_PATH("SIMPLE"),
.DIVR(4'b0000),		// DIVR =  0
.DIVF(7'b0111111),	// DIVF = 63
.DIVQ(3'b100),		// DIVQ =  5
.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1



) uut (
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .REFERENCECLK(crystal),
    .PLLOUTCORE(pll_clock)
);
endmodule


