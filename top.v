`default_nettype none
module top (xtal, debug_pin, fire_burst, dac_zero, dac_one, a_x, b_x, armed, txchain_en);
    input wire xtal;


    wire sample_strobe;
    wire bitwire;
    wire pll_clock;
    wire tsugi;
    /* verilator lint_off UNUSED */
    wire iq_tsugi;
    /* verilator lint_on UNUSED */

    input wire fire_burst;
    output wire armed;
    output wire txchain_en;


    wire [8:0] itmp;
    wire [8:0] qtmp;

    output reg [5:0] dac_zero;
    output reg [5:0] dac_one;
output reg [8:0] a_x;
output reg [8:0] b_x;

    output wire debug_pin;
    /* verilator lint_off UNUSED */
    reg tmp, tmp_2;
    wire [8:0] q_tc;
    wire [8:0] i_tc;
    wire [7:0] lfsr_debug;
    wire xxx;
    assign a_x = i_tc+ 255;
    assign b_x = q_tc + 255;

    /* verilator lint_on UNUSED */
    always @(posedge pll_clock) begin
        dac_zero <= i_tc[8:3] + 32;
        dac_one  <= q_tc[8:3] + 32;
    end // always @(posedge pll_clock)
    assign debug_pin = iq_tsugi;
    icepll pll(xtal, pll_clock);
    //assign pll_clock = xtal;
    gmsk_modulate modulator (
        .clock(pll_clock),
        .current_symbol_i(bitwire),
        .sample_strobe_i(sample_strobe),
        .iq_symbol_edge_o(iq_tsugi),
        .inphase_out(itmp),
        .quadrature_out(qtmp),
        .symbol_strobe_o(tsugi));

    tx_burst modulator_control(
        .clock(pll_clock),
        .symbol_strobe_i(tsugi),
        .iq_symbol_edge_i(iq_tsugi),
        .current_symbol_o(bitwire),
        .sample_strobe(sample_strobe),
        .fire_burst(fire_burst),
        .is_armed(armed),
        .modulator_inphase(itmp),
        .modulator_quadrature(qtmp),
        .rfchain_inphase(i_tc),
        .rfchain_quadrature(q_tc),
        .debug_pin(xxx),
        .iq_valid(txchain_en));

endmodule

