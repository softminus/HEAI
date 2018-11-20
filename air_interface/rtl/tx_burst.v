`default_nettype none

/* 
 * GMSK modulator timing, initialisation, and feeding
 */

module tx_burst
(
    input wire clock,

    // timing
    input wire symbol_input_strobe, // high when the modulator expects a new symbol
    input wire symbol_iq_strobe,    // high on the first I/Q samples of the next symbol
    output reg current_symbol,      // value of symbol to emit

    output wire sample_strobe,      // we assert this every sample-interval

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
    localparam CLOCKS_PER_SAMPLE = 5;

    reg [(ROM_OUTPUT_BITS-1+1):0] pipeline_inphase;
    reg [(ROM_OUTPUT_BITS-1+1):0] pipeline_quadrature;
    reg reset;
    reg [3:0] priming;
    reg lockout;
    reg primed;

    reg [(CLOCKS_PER_SAMPLE-1):0] clkdiv;

    always @(posedge clock) begin
        if (reset == 0) begin
            priming <= 4'b1111;
            reset   <= 1;
            clkdiv  <= 1;
        end else begin
            clkdiv <= {clkdiv[(CLOCKS_PER_SAMPLE-2):0], clkdiv[(CLOCKS_PER_SAMPLE-1)]};
            sample_strobe <= 1; //clkdiv[0];
        end // end else

        if (priming != 0) begin
            current_symbol <= 1;
            if ((lockout == 0) && (symbol_input_strobe == 1)) begin
                lockout <= 1;
                priming <= {1'b0, priming[3:1]};
            end // if (symbol_input_strobe == 1)
            if (symbol_input_strobe == 0) begin
                lockout <= 0;
            end // if ((lockout == 1) && (symbol_input_strobe == 0))
        end // if (priming != 0)

        if ((priming == 0) && (primed == 0)) begin
            if (symbol_iq_strobe == 1) begin
                primed <= 1;
            end // if (symbol_iq_strobe == 1)
        end // if ((priming == 0) && (primed == 0))
        pipeline_inphase <= modulator_inphase;
        pipeline_quadrature <= modulator_quadrature;
        if (primed == 0) begin
            rfchain_inphase <= 1;
            rfchain_quadrature <= 1;
            iq_valid <= 0;
        end else begin
            rfchain_inphase    <= pipeline_inphase;
            rfchain_quadrature <= pipeline_quadrature;
            iq_valid <= 1;
            current_symbol <= 0;
        end // end else
    end
endmodule // tx_burst