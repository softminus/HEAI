`default_nettype none
module top (crystal, dac_zero, dac_one);
    input crystal;
    wire pll_clock;

    output reg [5:0] dac_zero = 0;
    output reg [5:0] dac_one = 0;
    
    reg clk_en = 1;
    reg [7:0] pi = 3;
    reg [7:0] pi_two = 2;

//    icepll chip_pll(crystal, pll_clock);

    assign pll_clock = crystal;
    wire [4:0] rfi;
    wire [4:0] loi;
    wire [4:0] loq;
/* verilator lint_off UNUSED */
    reg [11:0] tmpi;
    wire [4:0] rfq;
    reg [11:0] tmpq;

    nco lo_nco(pll_clock, clk_en, pi, loi, loq);
    nco rf_nco(pll_clock, clk_en, pi_two, rfi, rfq);
/* verilator lint_off WIDTH */
    complex_mixer mix(pll_clock, clk_en, rfi, rfq, loi, loq, tmpi, tmpq);

    always @(posedge pll_clock) begin
        dac_one <=  $signed(tmpq[11:7])+32;
        dac_zero <= $signed(tmpi[11:7]) + 32;
    end
endmodule

