`default_nettype none
module top (xtal, debug_pin, fire_burst, dac_zero, dac_one, armed, txchain_en);
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

    output wire [5:0] dac_zero;
    output wire [5:0] dac_one;

    output wire debug_pin;
    /* verilator lint_off UNUSED */
    reg tmp, tmp_2;
    wire [8:0] q_tc;
    wire [8:0] i_tc;
    wire [7:0] lfsr_debug;
    reg [5:0] a;
    reg [5:0] b;
    assign dac_zero = a;
    assign dac_one = b;
    wire xxx;
    /* verilator lint_on UNUSED */
    always @(posedge pll_clock) begin
        a <= i_tc[8:3] + 32;
        b  <= q_tc[8:3] + 32;
    end // always @(posedge pll_clock)
    assign debug_pin = pll_clock;
    //icepll pll(xtal, pll_clock);
    assign pll_clock = xtal;
    gmsk_modulate modulator (
        .clock(pll_clock),
        .current_symbol(bitwire),
        .sample_strobe(sample_strobe),
        .symbol_beginning(iq_tsugi),
        .inphase_out(itmp),
        .quadrature_out(qtmp),
        .next_symbol_strobe(tsugi));

    tx_burst modulator_control(
        .clock(pll_clock),
        .symbol_input_strobe(tsugi),
        .symbol_iq_strobe(iq_tsugi),
        .current_symbol_o(bitwire),
        .sample_strobe(sample_strobe),
        .fire_burst(fire_burst),
        .is_armed(armed),
        .modulator_inphase(itmp),
        .modulator_quadrature(qtmp),
        .rfchain_inphase(i_tc),
        .rfchain_quadrature(q_tc),
        .debug_pin(xxx),
        .lfsr(lfsr_debug),
        .iq_valid(txchain_en));

endmodule

