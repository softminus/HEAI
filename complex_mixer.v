`default_nettype none
module complex_mixer (clock, clk_en, rf_i, rf_q, lo_i, lo_q, if_i, if_q);
    input [4:0] rf_i;
    input [4:0] rf_q;

    input [4:0] lo_i;
    input [4:0] lo_q;


    output reg [9:0] if_i;
    output reg [9:0] if_q;

    input wire clock;
    input wire clk_en;

    always @ (posedge clock) begin
        if (clk_en == 1) begin
            if_i <= ($signed(rf_i) * $signed(lo_i)) - ($signed(rf_q) * $signed(lo_q));
            if_q <= ($signed(rf_i) * $signed(lo_q)) + ($signed(rf_q) * $signed(lo_i));
        end
    end
endmodule
