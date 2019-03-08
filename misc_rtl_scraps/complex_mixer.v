`default_nettype none
module complex_mixer (clock, clk_en, rf_i, rf_q, lo_i, lo_q, if_i, if_q);
    localparam IWIDTH = 8;
    localparam OWIDTH = 17;

    input [(IWIDTH-1):0] rf_i;
    input [(IWIDTH-1):0] rf_q;

    input [(IWIDTH-1):0] lo_i;
    input [(IWIDTH-1):0] lo_q;

    output reg [(OWIDTH-1):0] if_i;
    output reg [(OWIDTH-1):0] if_q;

    reg [(OWIDTH-1):0] tmp;
    reg [(OWIDTH-1):0] tmp_2;

    reg [(OWIDTH-1):0] tmp_3;
    reg [(OWIDTH-1):0] tmp_4;

    input wire clock;
    input wire clk_en;

    reg init = 0;

    always @ (posedge clock) begin
        if (clk_en == 1) begin
            if(init == 0)
            begin
               if_i <= 0;
               if_q <= 0;
               init <= 1;
            end else begin

                tmp   <= $signed(rf_i) * $signed(lo_i);
                tmp_2 <= $signed(rf_q) * $signed(lo_q);

                if_i <= tmp - tmp_2;

                tmp_3 <= $signed(rf_i) * $signed(lo_q);
                tmp_4 <= $signed(rf_q) * $signed(lo_i);


                if_q <= tmp_3 + tmp_4;
        end

        end
    end
endmodule
