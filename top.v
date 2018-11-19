`default_nettype none
module top (clock, fire_burst, out_i, out_q, armed, txchain_en);
    input clock;

    wire ss;
    wire bitwire;

    input wire fire_burst;
    output wire armed;
    output wire txchain_en;


    wire [7:0] itmp;
    wire [7:0] qtmp;

    output wire [7:0] out_i;
    output wire [7:0] out_q;

    
    gmsk_modulate tx(clock, bitwire, ss, itmp, qtmp);
    tx_burst bb(clock, ss, itmp, qtmp, bitwire, fire_burst, armed, txchain_en, out_i, out_q);

endmodule

