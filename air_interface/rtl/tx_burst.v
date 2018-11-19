`default_nettype none

/* 
 * GMSK modulator timing, initialisation, and feeding
 */

module tx_burst
(
    input wire clock,

    // modulator interface
    input wire next_symbol_strobe, // modulator is ready for next input symbol
    input wire [(ROM_OUTPUT_BITS-1+1):0] modulator_inphase,     // i from modulator
    input wire [(ROM_OUTPUT_BITS-1+1):0] modulator_quadrature,  // q from modulator
    output reg current_symbol,
    

    // control
    input wire fire_burst,         // assert to begin a burst
    output reg is_armed,
    
    // output I/Q samples
    output reg [(ROM_OUTPUT_BITS-1+1):0] rfchain_inphase,
    output reg [(ROM_OUTPUT_BITS-1+1):0] rfchain_quadrature,
    output reg rfchain_tx_enable // 1 iff valid I/Q samples are being output

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
            clkdiv <= {clkdiv[1:0], clkdiv[2]};
        end // end else


    end
endmodule // tx_burst