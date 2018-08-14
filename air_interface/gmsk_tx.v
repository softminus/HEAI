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
    input clock,
    input clk_en,

    input input_bit,
    input input_bit_strobe,

    output reg inphase_out,
    output reg inphase_strobe,
    output reg quadrature_out,
    output reg quadrature_strobe
);

    // XXX make sure this works with GSM data rate and clock, clock dividers
    // of system, check numerology!

    // XXX be very careful about whether to do sign fixup by setting the top bit or
    // by doing a proper 2s complement negation. endpoints and edge cases need
    // to be verified as properly handled since we need zero discontinuities.
    //
    input wire clock;
    input wire clk_en;

    input wire input_bit;
    input wire input_bit_strobe;

    localparam BITS_PER_SAMPLE = 8;

    output reg [(BITS_PER_SAMPLE-1):0] inphase_out;
    output reg [(BITS_PER_SAMPLE-1):0] quadrature_out;
    output reg inphase_strobe;
    output reg quadrature_strobe;





    


endmodule
