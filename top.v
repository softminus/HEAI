`default_nettype none
module top (crystal, rf_in_i, rf_in_q, lo_in_i, lo_in_q, out_i, out_q);
    input crystal;


    input reg [7:0] rf_in_i;
    input reg [7:0] rf_in_q;

    input reg [7:0] lo_in_i;
    input reg [7:0] lo_in_q;

    output reg [16:0] out_i;
    output reg [16:0] out_q;
    
    reg clk_en = 1;

    reg [7:0] a_i = 0;
    reg [7:0] a_q = 0;


    reg [7:0] b_i = 0;
    reg [7:0] b_q = 0;

    complex_mixer mix(crystal, clk_en, a_i, a_q, b_i, b_q, out_i, out_q);

    always @(posedge crystal) begin
        a_i <= rf_in_i;
        a_q <= rf_in_q;

        b_i <= lo_in_i;
        b_q <= lo_in_q;
    end
endmodule

