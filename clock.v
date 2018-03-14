`default_nettype none
module pll (input crystal, output pll_clock);
SB_PLL40_CORE #(
    .FEEDBACK_PATH("SIMPLE"),
    .PLLOUT_SELECT("GENCLK"),

    .DIVR(4'b0000),         // DIVR =  0
.DIVF(7'b0110110),      // DIVF = 54
.DIVQ(3'b101),          // DIVQ =  5
.FILTER_RANGE(3'b001)   // FILTER_RANGE = 1

) uut (
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .REFERENCECLK(crystal),
    .PLLOUTCORE(pll_clock)
);
endmodule


