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
    input wire fire_burst, // assert to begin a burst iff is_armed is high
    output reg is_armed,
    
    // I/Q sample handling
    input wire [(ROM_OUTPUT_BITS-1+1):0] modulator_inphase,
    input wire [(ROM_OUTPUT_BITS-1+1):0] modulator_quadrature,

    output reg [(ROM_OUTPUT_BITS-1+1):0] rfchain_inphase,
    output reg [(ROM_OUTPUT_BITS-1+1):0] rfchain_quadrature,
    output reg iq_valid // 1 iff valid I/Q samples are being output

);

    localparam ROM_OUTPUT_BITS = 7;

    reg reset;

    reg [2:0] priming;

    reg detent;

    always @(posedge clock) begin
        if (reset == 0) begin
            priming   <= 2;
            reset     <= 1;
        end

        if (priming != 0) begin
            current_symbol <= 1;
            if (next_symbol_strobe == 1) begin
                detent <= 1;
            end // if (next_symbol_strobe == 1)
            if ((detent == 1) && (next_symbol_strobe == 0)) begin
                detent <= 0;
                priming <= priming - 1;
            end // if ((detent == 1) && (next_symbol_strobe == 0))
        end

        inphase_out <= inphase_in;
        quadrature_out <= quadrature_in;
        if (reset == 0) begin
            reset <= 1;
            clkdiv <= 1;
        end else begin
            clkdiv <= {clkdiv[2:0], clkdiv[3]};
        end // end else

        if (clkdiv == 1)
        begin
            sample_strobe <= 1;
        end else begin
            sample_strobe <= 0;
        end


    end
endmodule // tx_burst