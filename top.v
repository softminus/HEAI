`default_nettype none
module top (clock, fire_burst, out_i, out_q, armed, txchain_en);
    input clock;

    wire sample_strobe;
    wire bitwire;
    wire tsugi;
    /* verilator lint_off UNUSED */
    wire iq_tsugi;
    /* verilator lint_on UNUSED */

    input wire fire_burst;
    output wire armed;
    output wire txchain_en;


    wire [7:0] itmp;
    wire [7:0] qtmp;

    output wire [7:0] out_i;
    output wire [7:0] out_q;

    
    gmsk_modulate modulator (
        .clock(clock),
        .current_symbol(bitwire),
        .sample_strobe(sample_strobe),
        .symbol_beginning(iq_tsugi),
        .inphase_out(itmp),
        .quadrature_out(qtmp),
        .next_symbol_strobe(tsugi));

    tx_burst modulator_control(
        .clock(clock),
        .next_symbol_strobe(tsugi),
        .current_symbol(bitwire),
        .sample_strobe(sample_strobe),
        .fire_burst(fire_burst),
        .is_armed(armed),
        .modulator_inphase(itmp),
        .modulator_quadrature(qtmp),
        .rfchain_inphase(out_i),
        .rfchain_quadrature(out_q),
        .iq_valid(txchain_en));


endmodule

