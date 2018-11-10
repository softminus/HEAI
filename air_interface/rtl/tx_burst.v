`default_nettype none

/* 
 * GMSK modulator initialisation/feeding/housekeeping
 */

module tx_burst
(
    input wire clock,

    // modulator interface
    input wire next_symbol_strobe, // modulator is ready for next input symbol
    input wire [(ROM_OUTPUT_BITS-1+1):0] inphase_in,     // i from modulator
    input wire [(ROM_OUTPUT_BITS-1+1):0] quadrature_in,  // q from modulator
    output reg current_symbol,
    

    // control
    input wire fire_burst,         // assert to begin a burst
    output reg armed,
    output reg tx_rf_chain_enable, // 1 iff valid I/Q samples are being output
    
    // output I/Q samples
    output reg [(ROM_OUTPUT_BITS-1+1):0] inphase_out,
    output reg [(ROM_OUTPUT_BITS-1+1):0] quadrature_out

);

    localparam ROM_OUTPUT_BITS = 7;

    reg [147:0] test_burst;
    
    reg reset;

    reg [2:0] priming;


    always @(posedge clock) begin
        if (reset == 0) begin
            priming   <= 2;
            reset     <= 1;
        end

        if (priming != 0) begin
            current_symbol <= 1;
            if (next_symbol_strobe == 1) begin
                priming <= priming - 1;
            end // if (next_symbol_strobe == 1)
        end 
    
    end



endmodule // tx_burst