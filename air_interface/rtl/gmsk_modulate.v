`default_nettype none

/* 
 * GMSK I/Q-modulator
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

module gmsk_modulate
(
    input wire clock,

    input wire current_symbol,
    input wire sample_strobe,

    output reg next_symbol_strobe,
    output reg symbol_beginning,

    output reg [(ROM_OUTPUT_BITS-1+1):0] inphase_out,
    output reg [(ROM_OUTPUT_BITS-1+1):0] quadrature_out
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

    localparam ROM_INDEX_BITS  = 8;
    localparam ROM_SIZE = 2 ** ROM_INDEX_BITS;

    localparam ROM_OUTPUT_BITS = 8;


    reg [(ROM_OUTPUT_BITS-1):0] master_curve_1 [0:(ROM_SIZE-1)];
    initial $readmemh("air_interface/gen/gmsk_curve_1.hex",master_curve_1);

    reg [(ROM_OUTPUT_BITS-1):0] master_curve_2 [0:(ROM_SIZE-1)];
    initial $readmemh("air_interface/gen/gmsk_curve_2.hex",master_curve_2);

    reg [(ROM_OUTPUT_BITS-1):0] master_curve_3 [0:(ROM_SIZE-1)];
    initial $readmemh("air_interface/gen/gmsk_curve_3.hex",master_curve_3);

    reg [(ROM_OUTPUT_BITS-1):0] master_curve_7 [0:(ROM_SIZE-1)];
    initial $readmemh("air_interface/gen/gmsk_curve_7.hex",master_curve_7);

    reg [(ROM_INDEX_BITS-1):0] index_rising;
    reg [(ROM_INDEX_BITS-1):0] index_falling;

    reg [(ROM_OUTPUT_BITS-1):0] rom_out_rising;
    reg [(ROM_OUTPUT_BITS-1):0] rom_out_falling;

    reg [(ROM_OUTPUT_BITS-1+1):0] sample_falling;
    reg [(ROM_OUTPUT_BITS-1+1):0] sample_rising;

    reg [(ROM_OUTPUT_BITS-1+1):0] inphase_tmp;
    reg [(ROM_OUTPUT_BITS-1+1):0] quadrature_tmp;

    /* tristimulus is a shift register that keeps track of the precursor symbol,
     * current symbol, and postcursor symbol. We make assumption that the gaussian
     * filter negligably affects pre-pre-cursor symbol or post-postcursor symbol
     */
    reg [2:0] tristimulus;

    reg [1:0] tristimulus_delay;
    reg [3:0] edge_output;

    /* where we are on the phase trellis influences what waveform to output, so we
     * add or subtract 1 from phase_quadrant_acc after we emit a symbol to keep
     * track of this.
     */
    reg [1:0] phase_quadrant_acc;
    reg [1:0] pq_tmp;
    reg [1:0] pq_delay;

    always @ (posedge clock) begin

        if (index_rising == ROM_SIZE-4) begin
            next_symbol_strobe <= 1;
        end else begin
            next_symbol_strobe <= 0;
        end // end else

        if (sample_strobe == 1) begin
            if (index_rising==ROM_SIZE-2) begin
                index_rising  <= 0;
                index_falling <= ROM_SIZE-1;
                phase_quadrant_acc <= phase_quadrant_acc + ((tristimulus[1]) ? 2'b01 : 2'b11);
                tristimulus <= {tristimulus[1:0], current_symbol};
                edge_output <= {edge_output[2:0], 1'b1};
            end else begin
                index_rising  <= index_rising  + 1;
                index_falling <= index_falling - 1;
                edge_output <= {edge_output[2:0], 1'b0};
            end // end else

            symbol_beginning <= edge_output[3];

            tristimulus_delay <= {tristimulus_delay[0], tristimulus[1]};

            pq_tmp <= phase_quadrant_acc;
            pq_delay <= pq_tmp;


            case (tristimulus)
                3'b000: rom_out_rising  <= master_curve_7[index_rising];
                3'b001: rom_out_rising  <= master_curve_1[index_rising];
                3'b010: rom_out_rising  <= master_curve_2[index_rising];
                3'b011: rom_out_rising  <= master_curve_3[index_rising];
                3'b100: rom_out_rising  <= master_curve_3[index_rising];
                3'b101: rom_out_rising  <= master_curve_2[index_rising];
                3'b110: rom_out_rising  <= master_curve_1[index_rising];
                3'b111: rom_out_rising  <= master_curve_7[index_rising];
            endcase // tristimulus
            case (tristimulus)
                3'b000: rom_out_falling <= master_curve_7[index_falling];
                3'b001: rom_out_falling <= master_curve_3[index_falling];
                3'b010: rom_out_falling <= master_curve_2[index_falling];
                3'b011: rom_out_falling <= master_curve_1[index_falling];
                3'b100: rom_out_falling <= master_curve_1[index_falling];
                3'b101: rom_out_falling <= master_curve_2[index_falling];
                3'b110: rom_out_falling <= master_curve_3[index_falling];
                3'b111: rom_out_falling <= master_curve_7[index_falling];
            endcase // tristimulus

            sample_rising  <= {1'b0, rom_out_rising };
            sample_falling <= {1'b0, rom_out_falling};

            if (tristimulus_delay[1] == 0)
            begin
                case (pq_delay)
                    2'b00: inphase_tmp <=  sample_falling;
                    2'b01: inphase_tmp <=  sample_rising;
                    2'b10: inphase_tmp <= -sample_falling;
                    2'b11: inphase_tmp <= -sample_rising;
                endcase // phase_quadrant_acc
                case (pq_delay)
                    2'b00: quadrature_tmp <= -sample_rising;
                    2'b01: quadrature_tmp <=  sample_falling;
                    2'b10: quadrature_tmp <=  sample_rising;
                    2'b11: quadrature_tmp <= -sample_falling;
                endcase // phase_quadrant_acc
            end else begin
                case (pq_delay)
                    2'b00: inphase_tmp <=  sample_falling;
                    2'b01: inphase_tmp <= -sample_rising;
                    2'b10: inphase_tmp <= -sample_falling;
                    2'b11: inphase_tmp <=  sample_rising;
                endcase // phase_quadrant_acc
                case (pq_delay)
                    2'b00: quadrature_tmp <=  sample_rising;
                    2'b01: quadrature_tmp <=  sample_falling;
                    2'b10: quadrature_tmp <= -sample_rising;
                    2'b11: quadrature_tmp <= -sample_falling;
                endcase // phase_quadrant_acc
            end // end else

            inphase_out <= inphase_tmp;
            quadrature_out <= quadrature_tmp;

        end // if (sample_strobe == 1)
    end // always @ (posedge clock)
endmodule
