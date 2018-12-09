`default_nettype none

/* 
 * GMSK modulator timing, initialisation, and feeding
 */

 // FIXME use higher number of bits in ROM and in rampup/rampdown tables and THEN truncate to DAC


 module tx_burst
     (
         input wire clock,

    // timing in/out from modulator
    output reg sample_strobe,      // we assert this every sample-interval
    input wire symbol_input_strobe, // high when the modulator expects a new symbol
    /* verilator lint_off UNUSED */

    input wire symbol_iq_strobe,    // high on the first I/Q samples of the next symbol
    /* verilator lint_on UNUSED */

    // modulator symbol interface
    output reg current_symbol_o,      // value of symbol to emit
    // I/Q sample interface
    input wire [(ROM_OUTPUT_BITS-1+1):0] modulator_inphase,
    input wire [(ROM_OUTPUT_BITS-1+1):0] modulator_quadrature,

    output reg [(ROM_OUTPUT_BITS-1+1):0] rfchain_inphase,
    output reg [(ROM_OUTPUT_BITS-1+1):0] rfchain_quadrature,
    /* verilator lint_off UNDRIVEN */
    output reg iq_valid, // 1 iff valid I/Q samples are being output (use to enable RF PA)
    /* verilator lint_on UNDRIVEN */


    // how we get controlled
    /* verilator lint_off UNUSED */
    input wire fire_burst, // assert to begin a burst iff is_armed is high
        /* verilator lint_on UNUSED */
        /* verilator lint_off UNDRIVEN */
        output reg is_armed,
        output wire debug_pin,
        output reg [7:0] lfsr
        /* verilator lint_on UNDRIVEN */
        );

     localparam ROM_OUTPUT_BITS = 8;
     localparam CLOCKS_PER_SAMPLE = 5;

    localparam MASK_SIZE = 512; // this is enumerated in I/Q-samples and not modulation symbols
    reg [7:0] half_mask [0:(MASK_SIZE-1)];
    initial $readmemh("air_interface/gen/half_mask.hex", half_mask);
    reg [8:0] rampup_sample_counter;
    reg [8:0] rampdown_sample_counter;
    reg [8:0] tmp;

    reg [8:0] mask; // "sign" extended
    reg [7:0] mask_t;
    /* verilator lint_off UNUSED */
    reg [17:0] tmp_i; // multiplication output
    reg [17:0] tmp_q; // multiplication output
    reg [17:0] tmp_qq;
    reg [17:0] tmp_ii;
    /* verilator lint_on UNUSED */


    reg [(ROM_OUTPUT_BITS-1+1):0] pipeline_inphase;
    reg [(ROM_OUTPUT_BITS-1+1):0] pipeline_quadrature;
    reg reset;
    reg [3:0] priming;
    reg lockout;

    reg [(CLOCKS_PER_SAMPLE-1):0] clkdiv;
    reg [7:0] lfsr = 1;

    reg [4:0] burst_state;
    reg [7:0] symcount;
    reg [9:0] iftime;

    assign debug_pin = current_symbol_o;
    localparam [7:0] LFSR_TAPS = 8'h8e;

    always @(posedge clock) begin
        if (reset == 0) begin
            priming <= 4'b1111;
            burst_state <= 5'b00001; // flush bubbles out of modulator pipeline
            reset   <= 1;
            clkdiv  <= 1;
            iftime  <= 1020;
        end else begin
            clkdiv <= {clkdiv[(CLOCKS_PER_SAMPLE-2):0], clkdiv[(CLOCKS_PER_SAMPLE-1)]};
            sample_strobe <= 1; //clkdiv[0];;
        end // end else

        // flush bubbles out of modulator pipeline and reset modulator state
        // also accept filling of bit buffer
        if (burst_state[0]) begin
            if ((lockout == 0) && (symbol_input_strobe == 1)) begin
                lockout <= 1;
                priming <= {1'b0, priming[3:1]};
            end // if (symbol_input_strobe == 1)
            if (symbol_input_strobe == 0) begin
                lockout <= 0;
            end // if ((lockout == 1) && (symbol_input_strobe == 0))
            rfchain_inphase <= 0;
            rfchain_quadrature <= 0;
            iq_valid <= 0;
            current_symbol_o <= 1;
            if (priming == 0) begin
                burst_state <= {burst_state[3:0],burst_state[4]};
            end // if (priming == 0)
        end // if (burst_state == 5'b00001)

        // Armed state. Ready to send
        if (burst_state[1]) begin
            rfchain_inphase <= 0;
            rfchain_quadrature <= 0;
            iq_valid <= 0;
            symcount <= 0;
            mask_t <= 00;
            mask   <= 00;
            iftime <= iftime - 1;
            if(iftime == 0) begin
                            rampup_sample_counter <= 0;
            rampdown_sample_counter <= 480;
            burst_state <= {burst_state[3:0],burst_state[4]};
            end // if(iftime == 0)
        end // if (burst_state == 5'b00010)

        // Sending
        if ((burst_state[2]) || (burst_state[3]) || (burst_state[4])) begin
            if (burst_state[2]) begin
                rampup_sample_counter <= rampup_sample_counter + 1;
                tmp <= rampup_sample_counter;
                mask_t <= half_mask[tmp];
                mask <= {1'b0, mask_t};
                if(rampup_sample_counter == 490) begin
                    burst_state <= {burst_state[3:0],burst_state[4]};
                end // if(rampup_sample_counter == 511)
            end // if (burst_state == 5'b00100)

            if (burst_state[3]) begin
                mask_t <= 8'b11111111;
                mask <= {1'b0, mask_t};
                if (symbol_input_strobe == 1) begin
                    symcount <= symcount + 1;
                    current_symbol_o <= lfsr[1]|1'b0;
                    if (lfsr[0]) begin
                        lfsr <= {1'b0, lfsr[7:1]} ^ LFSR_TAPS;
                    end else begin
                        lfsr <= {1'b0, lfsr[7:1]};
                    end // end else
                end // if (symbol_input_strobe == 1)
                if (symcount == 13) begin
                    burst_state <= {burst_state[3:0],burst_state[4]};
                end // if (symcount == 16)
            end // if (burst_state == 5'b01000)

            if (burst_state[4]) begin
                rampdown_sample_counter <= rampdown_sample_counter - 1;
                tmp <= rampdown_sample_counter;
                mask_t <= half_mask[tmp];
                mask <= {1'b0, mask_t};
                if(rampdown_sample_counter == 0) begin
                    burst_state <= {burst_state[3:0],burst_state[4]};
                    priming <= 4'b1111;
                end // if(rampdown_sample_counter == 0)
            end // if (burst_state == 5'b10000)


        pipeline_inphase    <= modulator_inphase;
        pipeline_quadrature <= modulator_quadrature;
        tmp_i <= $signed(pipeline_inphase)    * $signed(mask);
        tmp_q <= $signed(pipeline_quadrature) * $signed(mask);
        tmp_ii <= tmp_i;
        tmp_qq <= tmp_q;
        rfchain_inphase    <= tmp_ii[16:8];
        rfchain_quadrature <= tmp_qq[16:8];
        iq_valid <= 1;
        end // if (burst_state == 5'b00100)

    end // always @(posedge clock)
endmodule // tx_burst