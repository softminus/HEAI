`default_nettype none
module top (crystal, dac_zero, dac_one);
    input crystal;
    wire pll_clock;

    output reg [5:0] dac_zero = 0;
    output reg [5:0] dac_one = 0;
    
    reg clk_en = 1;
    reg [7:0] pi = 3;
    reg [7:0] pi_two = 13;

    icepll chip_pll(crystal, pll_clock);

    wire [4:0] rfi;
    wire [4:0] rfq;
    wire [4:0] loi;
    wire [4:0] loq;

    reg [9:0] tmpi;
    reg [9:0] tmpq;

    nco lo_nco(pll_clock, clk_en, pi, loi, loq);
    nco rf_nco(pll_clock, clk_en, pi_two, rfi, rfq);
    complex_mixer mix(pll_clock, clk_en, rfi, rfq, loi, loq, tmpi, tmpq);

    always @(posedge pll_clock) begin
        dac_one <=  $signed(tmpq[9:5])+32;
        dac_zero <= $signed(tmpi[9:5]) + 32;
    end
endmodule

