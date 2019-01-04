`default_nettype none

/* 
 * GMSK modulator timing, initialisation, and feeding
 */

 // FIXME use higher number of bits in ROM and in rampup/rampdown tables and THEN truncate to DAC
 // FIXME also do complete analysis of bit-widths everywhere and DOCUMENT it properly


module tx_burst (
    input wire clock,

    // we divide the system clock to generate a sample clock for the modulator
    output reg sample_strobe,

    // we feed symbols to the modulator ...
    output reg current_symbol_o,
    // ... when the modulator asserts this strobe:
    input wire symbol_strobe_i,    // high when the modulator expects a new symbol input
    // ...and the new symbol's I/Q samples begin when this is high:
    input wire iq_symbol_edge_i,   // high on the first I/Q samples of the next symbol


    // I/Q sample interface
    input wire [(ROM_OUTPUT_BITS-1+1):0] modulator_inphase,
    input wire [(ROM_OUTPUT_BITS-1+1):0] modulator_quadrature,

    output reg [(ROM_OUTPUT_BITS-1+1):0] rfchain_inphase,
    output reg [(ROM_OUTPUT_BITS-1+1):0] rfchain_quadrature,
    output reg iq_valid, // 1 iff valid I/Q samples are being output (feed this to RF chain)

    // how we get controlled
    /* verilator lint_off UNUSED */
    input wire fire_burst, // assert to begin a burst iff is_armed is high
    /* verilator lint_on UNUSED */
    /* verilator lint_off UNDRIVEN */
    output reg is_armed,
    output wire debug_pin
    /* verilator lint_on UNDRIVEN */
);

    localparam ROM_OUTPUT_BITS = 8;
    localparam CLOCKS_PER_SAMPLE = 3;
    localparam MASK_SIZE = 256; // this is enumerated in I/Q-samples and not modulation symbols
    /* verilator lint_off UNUSED */
    reg [7:0] half_mask [0:(MASK_SIZE-1)];
    initial $readmemh("air_interface/gen/half_mask.hex", half_mask);
    reg [7:0] mask_index;
    reg [7:0] mask_index_tmp;

    reg [8:0] mask; // "sign" extended
    reg [7:0] mask_t;
    /* verilator lint_off UNUSED */
    reg [17:0] tmp_i; // multiplication output
    reg [17:0] tmp_q; // multiplication output
    reg [17:0] tmp_qq;
    reg in_tail;
    reg [17:0] tmp_ii;
    /* verilator lint_on UNUSED */

    reg [(ROM_OUTPUT_BITS-1+1):0] pipeline_inphase;
    reg [(ROM_OUTPUT_BITS-1+1):0] pipeline_quadrature;
    reg reset;
    reg [3:0] priming;

    reg [(CLOCKS_PER_SAMPLE-1):0] clkdiv;
    reg [7:0] lfsr = 1;

    reg [4:0] burst_state = 1;
    wire new_symbol;
    wire samples_edge;
    reg [7:0] current_symbol_idx;
    reg [9:0] iftime;
    reg prev_bit, cur_bit;

    localparam MESSAGE_SIZE = 104;
    /* verilator lint_off UNUSED */

    reg message [0:(MESSAGE_SIZE-1)];
    /* verilator lint_on UNUSED */
    initial $readmemb("air_interface/gen/hello.bin", message);
    reg [6:0] message_bit_count;

    assign debug_pin = current_symbol_o;
    localparam [7:0] LFSR_TAPS = 8'h8e;

    always @(posedge clock) begin
        if (reset == 0) begin
            priming <= 4'b1111;
            burst_state <= 5'b00001; // flush bubbles out of modulator pipeline
            reset   <= 1;
            clkdiv  <= 1;
            iftime  <= 512;
            lfsr <= 1;
        end else begin
            clkdiv <= {clkdiv[(CLOCKS_PER_SAMPLE-2):0], clkdiv[(CLOCKS_PER_SAMPLE-1)]};
            sample_strobe <= 1;// clkdiv[0];
        end // end else


        // flush bubbles out of modulator pipeline and reset modulator state
        // also accept filling of bit buffer
        if (burst_state[0]) begin
            if (new_symbol == 1) begin
                current_symbol_o <= cur_bit ^ prev_bit;
                prev_bit <= cur_bit;
                cur_bit <= 1;
                priming <= {1'b0, priming[3:1]};
            end // if (new_symbol == 1)
            rfchain_inphase <= 0;
            rfchain_quadrature <= 0;
            iq_valid <= 0;
            if (priming == 0) begin
                burst_state <= {burst_state[3:0],burst_state[4]};
            end // if (priming == 0)
        end // if (burst_state == 5'b00001)

        // Armed state. Ready to send
        if (burst_state[1]) begin
            rfchain_inphase <= 0;
            rfchain_quadrature <= 0;
            iq_valid <= 0;
            current_symbol_idx <= 0;
            mask_t <= 00;
            mask   <= 00;
            if (iftime != 0) begin
                iftime <= iftime - 1;
            end else begin
                mask_index <= 0;
                mask_index_tmp <= 0;
                if (samples_edge == 1) begin
                burst_state <= {burst_state[3:0],burst_state[4]};
            end // end else
            end // if(iftime == 0)
        end // if (burst_state == 5'b00010)

        // Sending
        if ((burst_state[2]) || (burst_state[3]) || (burst_state[4])) begin
            if (burst_state[2] || burst_state[4]) begin
                if (sample_strobe == 1) begin
                current_symbol_o <= cur_bit ^ prev_bit;
                prev_bit <= cur_bit;
                cur_bit <= 0;
                    if (burst_state[4]) begin
                        mask_index <= mask_index - 1;
                    end else begin
                        mask_index <= mask_index + 1;
                    end // end else
                end // if (sample_strobe == 1)
                mask_index_tmp <= mask_index;
                mask_t <= half_mask[mask_index_tmp];
                mask <= {1'b0, mask_t};
                if (samples_edge == 1) begin
                    current_symbol_idx <= current_symbol_idx + 1;
                    if (burst_state[4]) begin
                        priming <= 4'b1111;
                    end // if (burst_state[4])
                    burst_state <= {burst_state[3:0], burst_state[4]};
                end // if(rampup_sample_counter == 511)
            end // if (burst_state == 5'b00100)

            if (burst_state[3]) begin
                mask_t <= 8'b11111111;
                mask <= {1'b0, mask_t};
                if (new_symbol == 1) begin
                    if ((current_symbol_idx < 10) || (current_symbol_idx > 125)) begin
                        in_tail <= 1;
                        current_symbol_o <= cur_bit ^ prev_bit;
                        prev_bit <= cur_bit;
                        cur_bit <= 0;
                    end else begin
                        message_bit_count <= message_bit_count + 1;
                        in_tail <= 0;
//                        current_symbol_o <= cur_bit ^ prev_bit;
//                        prev_bit <= cur_bit;
                        current_symbol_o <= message[message_bit_count];
                    end // end else
                    if (lfsr[0]) begin
                        lfsr <= {1'b0, lfsr[7:1]} ^ LFSR_TAPS;
                    end else begin
                        lfsr <= {1'b0, lfsr[7:1]};
                    end // end else
                end // if (new_symbol == 1)
                if (samples_edge == 1) begin
                    current_symbol_idx <= current_symbol_idx + 1;
                end // if (samples_edge == 1)

                if (current_symbol_idx == 128) begin
                    burst_state <= {burst_state[3:0], burst_state[4]};
                    iftime <= 1021;
                    mask_index <= 255;
                    mask_index_tmp <= 255;
                end // if (current_symbol_idx == 16)
            end // if (burst_state == 5'b01000)
        pipeline_inphase    <= modulator_inphase;
        pipeline_quadrature <= modulator_quadrature;
        tmp_i <= $signed(pipeline_inphase)    * $signed(mask);
        tmp_q <= $signed(pipeline_quadrature) * $signed(mask);
        tmp_ii <= tmp_i;
        tmp_qq <= tmp_q;
        rfchain_inphase    <= tmp_ii[16:8];
        rfchain_quadrature <= tmp_qq[16:8];
        iq_valid <= 1; // FIXME enable with appropriate strobe from modulator!
        end // if (burst_state == 5'b00100)

    end // always @(posedge clock)

    multirate_strobe mod_in_stb  (.clock(clock), .slow_strobe(symbol_strobe_i),  .fast_strobe(new_symbol));
    multirate_strobe mod_out_stb (.clock(clock), .slow_strobe(iq_symbol_edge_i), .fast_strobe(samples_edge));

endmodule // tx_burst
