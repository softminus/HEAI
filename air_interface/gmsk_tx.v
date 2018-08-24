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
    input wire symbol_strobe,
    input wire sample_strobe,

    /* verilator lint_off UNUSED */
    input wire clk_en,

//    input wire input_bit,
//    input wire input_bit_strobe,
    /* verilator lint_on UNUSED */

    output reg [(BITS_PER_SAMPLE-1):0] inphase_out
    /* verilator lint_off UNDRIVEN */
//    output reg [(BITS_PER_SAMPLE-1):0] quadrature_out
//    output reg inphase_strobe,
//    output reg quadrature_strobe
    /* verilator lint_on UNDRIVEN */
);

    // XXX make sure this works with GSM data rate and clock, clock dividers
    // of system, check numerology!

    // XXX be very careful about whether to do sign fixup by setting the top bit or
    // by doing a proper 2s complement negation. endpoints and edge cases need
    // to be verified as properly handled since we need zero discontinuities.
    //
    //
    // XXX DANGER XXX be careful about 2s complement asymmetry concerns whilst
    // negating the output of the ROM tables

    localparam BITS_PER_SAMPLE = 8;
    localparam SAMPLES_PER_SYMBOL = 128;
    localparam CLOCKS_PER_SAMPLE  = 8;



    reg [(BITS_PER_SAMPLE-1):0] master_curve_1 [0:(SAMPLES_PER_SYMBOL-1)];
    initial $readmemh("gmsk_curve_1.hex",master_curve_1);
    /* verilator lint_off UNUSED */
    reg [(BITS_PER_SAMPLE-1):0] master_curve_2 [0:(SAMPLES_PER_SYMBOL-1)];
    initial $readmemh("gmsk_curve_1.hex",master_curve_2);

    reg [(BITS_PER_SAMPLE-1):0] master_curve_3 [0:(SAMPLES_PER_SYMBOL-1)];
    initial $readmemh("gmsk_curve_1.hex",master_curve_3);

    reg [(BITS_PER_SAMPLE-1):0] master_curve_7 [0:(SAMPLES_PER_SYMBOL-1)];
    initial $readmemh("gmsk_curve_1.hex",master_curve_7);
    /* verilator lint_on UNUSED */

    reg [7:0] counter;
    reg rom_lookup;
    reg [7:0] rom_out;


    always @ (posedge clock) begin
        if (symbol_strobe == 1) begin
            counter <= 0;
        end else if (sample_strobe == 1) begin
            counter <= counter + 1;
        end

        rom_out <= master_curve_1[counter[6:0]];
        inphase_out <= -rom_out;
        rom_lookup <= ~rom_lookup;
    end // always @ (posedge clock)




endmodule
