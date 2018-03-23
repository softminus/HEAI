`default_nettype none
module top (crystal, dac_zero, dac_one);
    input crystal;
    wire pll_clock;

    output reg [5:0] dac_zero = 0;
    output reg [5:0] dac_one = 0;
    
    reg clk_en = 1;
    reg [7:0] pi = 1;

    icepll chip_pll(crystal, pll_clock);

    wire [4:0] sinout;
    wire [4:0] cosout;
    wire [5:0] debug_out;

    nco nco_under_test(pll_clock, clk_en, pi, sinout, cosout, debug_out);

    always @(posedge pll_clock) begin
        dac_zero <= $signed(sinout)+32;
        dac_one <=  $signed(cosout)+32;
    end
endmodule

