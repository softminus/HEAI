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
    /* LCs          226 / 7680 */
    function [3:0] quarter_sin;
        input [5:0] phase;
                case (phase)
                    6'b000000: quarter_sin = 4'b0000;
                    6'b000001: quarter_sin = 4'b0000;
                    6'b000010: quarter_sin = 4'b0000;
                    6'b000011: quarter_sin = 4'b0001;
                    6'b000100: quarter_sin = 4'b0001;
                    6'b000101: quarter_sin = 4'b0001;
                    6'b000110: quarter_sin = 4'b0010;
                    6'b000111: quarter_sin = 4'b0010;
                    6'b001000: quarter_sin = 4'b0011;
                    6'b001001: quarter_sin = 4'b0011;
                    6'b001010: quarter_sin = 4'b0011;
                    6'b001011: quarter_sin = 4'b0100;
                    6'b001100: quarter_sin = 4'b0100;
                    6'b001101: quarter_sin = 4'b0101;
                    6'b001110: quarter_sin = 4'b0101;
                    6'b001111: quarter_sin = 4'b0101;
                    6'b010000: quarter_sin = 4'b0110;
                    6'b010001: quarter_sin = 4'b0110;
                    6'b010010: quarter_sin = 4'b0110;
                    6'b010011: quarter_sin = 4'b0111;
                    6'b010100: quarter_sin = 4'b0111;
                    6'b010101: quarter_sin = 4'b0111;
                    6'b010110: quarter_sin = 4'b1000;
                    6'b010111: quarter_sin = 4'b1000;
                    6'b011000: quarter_sin = 4'b1000;
                    6'b011001: quarter_sin = 4'b1001;
                    6'b011010: quarter_sin = 4'b1001;
                    6'b011011: quarter_sin = 4'b1001;
                    6'b011100: quarter_sin = 4'b1010;
                    6'b011101: quarter_sin = 4'b1010;
                    6'b011110: quarter_sin = 4'b1010;
                    6'b011111: quarter_sin = 4'b1011;
                    6'b100000: quarter_sin = 4'b1011;
                    6'b100001: quarter_sin = 4'b1011;
                    6'b100010: quarter_sin = 4'b1011;
                    6'b100011: quarter_sin = 4'b1100;
                    6'b100100: quarter_sin = 4'b1100;
                    6'b100101: quarter_sin = 4'b1100;
                    6'b100110: quarter_sin = 4'b1100;
                    6'b100111: quarter_sin = 4'b1101;
                    6'b101000: quarter_sin = 4'b1101;
                    6'b101001: quarter_sin = 4'b1101;
                    6'b101010: quarter_sin = 4'b1101;
                    6'b101011: quarter_sin = 4'b1101;
                    6'b101100: quarter_sin = 4'b1110;
                    6'b101101: quarter_sin = 4'b1110;
                    6'b101110: quarter_sin = 4'b1110;
                    6'b101111: quarter_sin = 4'b1110;
                    6'b110000: quarter_sin = 4'b1110;
                    6'b110001: quarter_sin = 4'b1110;
                    6'b110010: quarter_sin = 4'b1111;
                    6'b110011: quarter_sin = 4'b1111;
                    6'b110100: quarter_sin = 4'b1111;
                    6'b110101: quarter_sin = 4'b1111;
                    6'b110110: quarter_sin = 4'b1111;
                    6'b110111: quarter_sin = 4'b1111;
                    6'b111000: quarter_sin = 4'b1111;
                    6'b111001: quarter_sin = 4'b1111;
                    6'b111010: quarter_sin = 4'b1111;
                    6'b111011: quarter_sin = 4'b1111;
                    6'b111100: quarter_sin = 4'b1111;
                    6'b111101: quarter_sin = 4'b1111;
                    6'b111110: quarter_sin = 4'b1111;
                    6'b111111: quarter_sin = 4'b1111;
                    default: quarter_sin = 4'b0000; // should never happen 

                endcase
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

