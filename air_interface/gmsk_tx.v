`default_nettype none

/* 
 * GMSK modulator
 *
 * We use the scheme explained in Linz1996 (doi://10.1109/82.481470). We
 * ingest data and use logic to generate addresses into a ROM with successive
 * samples of Gaussian-filtered sines. Symmetries are exploited to reduce ROM
 * size requirements, thus signs of ROM entries are fixed-up before being
 * output as I and Q samples. 
 *
 *
 * I am unsure whether this needs any kind of post-filtering, so please do not
 * emit RF with this!
*/

module gmsk_tx
(
    input wire clock,
    /* verilator lint_off UNUSED */
    input wire clk_en,

    input wire input_bit,
    input wire input_bit_strobe,
    /* verilator lint_on UNUSED */

    output reg [(BITS_PER_SAMPLE-1):0] inphase_out,
    /* verilator lint_off UNDRIVEN */
    output reg [(BITS_PER_SAMPLE-1):0] quadrature_out,
    output reg inphase_strobe,
    output reg quadrature_strobe
    /* verilator lint_on UNDRIVEN */
);

    // XXX make sure this works with GSM data rate and clock, clock dividers
    // of system, check numerology!

    // XXX be very careful about whether to do sign fixup by setting the top bit or
    // by doing a proper 2s complement negation. endpoints and edge cases need
    // to be verified as properly handled since we need zero discontinuities.
    //

    localparam BITS_PER_SAMPLE = 8;


    reg [7:0] master_curve_1 [0:127];
    initial $readmemh("gmsk_curve_1.hex",master_curve_1);

    reg [7:0] counter;


    always @ (posedge clock) begin
        counter <= counter + 1;

        inphase_out <= master_curve_1[counter[6:0]];



    end // always @ (posedge clock)




endmodule
