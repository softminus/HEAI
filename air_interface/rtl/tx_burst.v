`default_nettype none

/* 
 * GMSK modulator timing, initialisation, and feeding
 */

module tx_burst
(
    input wire clock,

    // timing
    input wire next_symbol_strobe, // modulator asserts this every symbol-interval,
    output reg current_symbol,     // ...so we can feed symbols to the modulator

    output reg sample_strobe,      // we assert this every sample-interval

    // control
    /* verilator lint_off UNUSED */
    input wire fire_burst, // assert to begin a burst iff is_armed is high
    /* verilator lint_on UNUSED */
    /* verilator lint_off UNDRIVEN */
    output reg is_armed,
    /* verilator lint_on UNDRIVEN */


    // I/Q sample handling
    input wire [(ROM_OUTPUT_BITS-1+1):0] modulator_inphase,
    input wire [(ROM_OUTPUT_BITS-1+1):0] modulator_quadrature,

    output reg [(ROM_OUTPUT_BITS-1+1):0] rfchain_inphase,
    output reg [(ROM_OUTPUT_BITS-1+1):0] rfchain_quadrature,
    /* verilator lint_off UNDRIVEN */
    output reg iq_valid // 1 iff valid I/Q samples are being output
    /* verilator lint_on UNDRIVEN */

);

    localparam ROM_OUTPUT_BITS = 7;
    localparam CLOCKS_PER_SAMPLE = 4;


    reg reset;
    reg [3:0] priming;
    reg detent;

    reg [(CLOCKS_PER_SAMPLE-1):0] clkdiv;

    always @(posedge clock) begin
        if (reset == 0) begin
            priming <= 4'b1111;
            reset   <= 1;
            clkdiv  <= 1;
        end else begin
            clkdiv <= {clkdiv[(CLOCKS_PER_SAMPLE-2):0], clkdiv[(CLOCKS_PER_SAMPLE-1)]};
        end // end else

        if (priming != 0) begin
            current_symbol <= 1;
            if (next_symbol_strobe == 1) begin
                detent <= 1;
            end // if (next_symbol_strobe == 1)
            if ((detent == 1) && (next_symbol_strobe == 0)) begin
                detent <= 0;
                priming <= {1'b0, priming[3:1]};
            end // if ((detent == 1) && (next_symbol_strobe == 0))
        end // if (priming != 0)


        if (clkdiv == 1)
        begin
            sample_strobe <= 1;
        end else begin
            sample_strobe <= 0;
        end

        if (priming != 0) begin
            rfchain_inphase <= 0;
            rfchain_quadrature <= 0;
            iq_valid <= 0;
        end else begin
            rfchain_inphase    <= modulator_inphase;
            rfchain_quadrature <= modulator_quadrature;
            iq_valid <= 1;
        end // end else
    end
endmodule // tx_burst