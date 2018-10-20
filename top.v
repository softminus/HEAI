`default_nettype none
module top (crystal, sy_st, sa_st, in_bits, out_i, out_q);
    input crystal;

    input wire sy_st, sa_st, in_bits;

    output reg [7:0] out_i;
    output reg [7:0] out_q;
    
    gmsk_tx tx(crystal, sy_st, sa_st, in_bits, out_i, out_q);

endmodule

