`default_nettype none
module top (crystal, dac_zero, dac_one);
    input crystal;
    wire pll_clock;

    wire clk_en;

    output reg [5:0] dac_zero = 0;
    output reg [5:0] dac_one = 0;
    
    reg clk_en = 1;
    reg pi = 1;

    pll chip_pll(crystal, pll_clock);

    signed wire [3:0] sinout;
    signed wire [3:0] cosout;

    nco nco_under_test(pll_clock, clk_en, pi, sinout, cosout);

    
    reg [31:0] counter = 0;


    always @(posedge pll_clock) begin
        counter <= counter + 1;
        dac_zero <= sinout + 8;
        dac_one <= cosout + 8;
    end
endmodule

