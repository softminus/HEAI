`default_nettype none
module top (xtal, debug_pin, fire_burst, dac_zero, dac_one, armed, txchain_en);
    input wire xtal;

    wire sample_strobe;
    wire bitwire;
    wire tsugi;
    /* verilator lint_off UNUSED */
    wire iq_tsugi;
    /* verilator lint_on UNUSED */

    input wire fire_burst;
    output wire armed;
    output wire txchain_en;


    wire [5:0] itmp;
    wire [5:0] qtmp;

    output reg [5:0] dac_zero;
    output reg [5:0] dac_one;

    wire [5:0] q_tc;
    output wire debug_pin;
    /* verilator lint_off UNUSED */
    reg tmp, tmp_2;
    wire [5:0] i_tc;
    wire [7:0] lfsr_debug;
    wire xxx;
    /* verilator lint_on UNUSED */
    always @(posedge xtal) begin
        dac_zero <= i_tc + 31;
        dac_one <= q_tc + 31;
        debug_pin <= tmp_2;
        tmp <= iq_tsugi;
        tmp_2 <= tmp;
    end // always @(posedge xtal)

    gmsk_modulate modulator (
        .clock(xtal),
        .current_symbol(bitwire),
        .sample_strobe(sample_strobe),
        .symbol_beginning(iq_tsugi),
        .inphase_out(itmp),
        .quadrature_out(qtmp),
        .next_symbol_strobe(tsugi));

    tx_burst modulator_control(
        .clock(xtal),
        .symbol_input_strobe(tsugi),
        .symbol_iq_strobe(iq_tsugi),
        .current_symbol(bitwire),
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

