`default_nettype none
module nco (clock, clk_en, phase_increment, sine_bits, cosine_bits, debug_pulse);
    /* I/O */
    output reg [4:0] sine_bits;
    output reg [4:0] cosine_bits;

    output reg [5:0] debug_pulse;

    input wire clk_en;

    input wire [7:0] phase_increment;

    input wire clock;


    reg [5:0] idx_sin;
    reg [5:0] idx_cos;

    reg [1:0] flip_sin;
    reg [1:0] flip_cos;
    reg [4:0] sin_reg;
    reg [4:0] cos_reg;

    reg [4:0] quarter_wave [0:63];
    initial $readmemh("qwave_6i_4o.hex",quarter_wave);


    /* state */
    reg [7:0] counter = 0;  /* runs at clock from 0 to 255 */
    wire [7:0] counter_cos;  /* runs at clock from 0 to 255 */
    /* LCs          78 / 7680 */

    function [5:0] synth_index;
        input [7:0] phase;
        case( {phase[7:6]} )
            2'b00: synth_index = phase[5:0];
            2'b01: synth_index = ~phase[5:0];
            2'b10: synth_index = phase[5:0];
            2'b11: synth_index = ~phase[5:0];
        endcase
    endfunction

    assign counter_cos = counter + 64;
    always @ (posedge clock) begin
        if (clk_en == 1) begin
            counter <= counter + phase_increment;

            flip_sin[0] <= counter[7];
            flip_sin[1] <= flip_sin[0];


            flip_cos[0] <= counter_cos[7];
            flip_cos[1] <= flip_cos[0];

            idx_sin <= synth_index (counter);
            idx_cos <= synth_index (counter_cos);

            sin_reg <= quarter_wave[idx_sin];
            cos_reg <= quarter_wave[idx_cos];

            if (flip_sin[1])
            begin
                sine_bits <= -sin_reg;
            end else begin
                sine_bits <= sin_reg;
            end

            if (flip_cos[1])
            begin
                cosine_bits <= -cos_reg;
            end else begin
                cosine_bits <= cos_reg;
            end





//            debug_pulse <= counter[7:2];
    end
    end /* begin */
    endmodule

