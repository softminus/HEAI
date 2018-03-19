`default_nettype none
module nco (clock, clk_en, phase_increment, sine_bits, cosine_bits);
    /* I/O */
    output reg [3:0] sine_bits;
    output reg [3:0] cosine_bits;

    input wire clk_en;

    input wire [7:0] phase_increment;

    input wire clock;

    /* state */
    reg [7:0] counter = 0;  /* runs at clock from 0 to 255 */

    function [3:0] quarter_sin;
        input [7:0] phase;
        if (phase == 0)  begin
            quarter_sin = 0;
        end else if (phase < 3) begin
            quarter_sin = 1;
        end else if (phase < 5) begin
            quarter_sin = 2;
        end else if (phase < 8) begin
            quarter_sin = 3;
        end else if (phase < 11) begin
            quarter_sin = 4;
        end else if (phase < 14) begin
            quarter_sin = 5;
        end else if (phase < 17) begin
            quarter_sin = 6;
        end else if (phase < 20) begin
            quarter_sin = 7;
        end else if (phase < 22) begin
            quarter_sin = 8;
        end else if (phase < 26) begin
            quarter_sin = 9;
        end else if (phase < 30) begin
            quarter_sin = 10;
        end else if (phase < 33) begin
            quarter_sin = 11;
        end else if (phase < 38) begin
            quarter_sin = 12;
        end else if (phase < 43) begin
            quarter_sin = 13;
        end else if (phase < 49) begin
            quarter_sin = 14;
        end else if (phase < 64) begin
            quarter_sin = 15;
        end
    endfunction

    function [3:0] whole_sin;
        input [7:0] phase;
        if (phase < 64) begin
            whole_sin = quarter_sin(phase) / 2;
        end else if (phase < 128) begin
            whole_sin = quarter_sin(128 - phase)  / 2 ;
        end else if (phase < 192) begin
            whole_sin = - quarter_sin(phase - 128)/2;
        end else begin
            whole_sin = - quarter_sin(256 - phase)/2;
        end
    endfunction

    always @ (posedge clock) begin
        if (clk_en == 1) begin
            counter <= counter + phase_increment;
        end
        sine_bits <= whole_sin(counter);
        cosine_bits <= whole_sin(counter + 64);
    end /* begin */
endmodule

