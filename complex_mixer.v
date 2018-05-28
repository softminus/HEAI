`default_nettype none
module complex_mixer (clock, clk_en, rf_i, rf_q, lo_i, lo_q, if_i, if_q);
    localparam IWIDTH = 8;
    localparam OWIDTH = 16;

    input [(IWIDTH-1):0] rf_i;
    input [(IWIDTH-1):0] rf_q;

    input [(IWIDTH-1):0] lo_i;
    input [(IWIDTH-1):0] lo_q;


    output reg [(OWIDTH-1):0] if_i;
    output reg [(OWIDTH-1):0] if_q;

    reg [(IWIDTH-1):0] t_rf_i;
    reg [(IWIDTH-1):0] t_rf_q;

    reg [(IWIDTH-1):0] t_lo_i;
    reg [(IWIDTH-1):0] t_lo_q;

    reg [(OWIDTH-1):0] product_aibi;
    reg [(OWIDTH-1):0] product_aqbq;

    reg [(OWIDTH-1):0] product_aibq;
    reg [(OWIDTH-1):0] product_aqbi;

    reg [(OWIDTH-1):0] product_aibi_t;
    reg [(OWIDTH-1):0] product_aqbq_t;
    reg [(OWIDTH-1):0] product_aibq_t;
    reg [(OWIDTH-1):0] product_aqbi_t;

    reg [(OWIDTH-1):0] product_aibi_t1;
    reg [(OWIDTH-1):0] product_aqbq_t1;
    reg [(OWIDTH-1):0] product_aibq_t1;
    reg [(OWIDTH-1):0] product_aqbi_t1;

    reg [(OWIDTH-1):0] product_aibi_t2;
    reg [(OWIDTH-1):0] product_aqbq_t2;
    reg [(OWIDTH-1):0] product_aibq_t2;
    reg [(OWIDTH-1):0] product_aqbi_t2;

    reg [(OWIDTH-1):0] product_aibi_t3;
    reg [(OWIDTH-1):0] product_aqbq_t3;
    reg [(OWIDTH-1):0] product_aibq_t3;
    reg [(OWIDTH-1):0] product_aqbi_t3;

    reg [(OWIDTH-1):0] sum_i;
    reg [(OWIDTH-1):0] sum_q;

    input wire clock;
    input wire clk_en;

    reg init = 0;

    always @ (posedge clock) begin
        if (clk_en == 1) begin
            if(init == 0)
            begin
               if_i <= 16'b0000011111111111;
               if_q <= 16'b0000011111111111;
                init <= 1;
            end else begin


            t_rf_i <= rf_i;
            t_rf_q <= rf_q;

            t_lo_i <= lo_i;
            t_lo_q <= lo_q;


            product_aibi <= ($signed(t_rf_i) * $signed(t_lo_i));
            product_aibi_t  <= product_aibi;
            product_aibi_t1 <= product_aibi_t;
            product_aibi_t2 <= product_aibi_t1;
            product_aibi_t3 <= product_aibi_t2;
            product_aqbq <= ($signed(t_rf_q) * $signed(t_lo_q));
            product_aqbq_t  <= product_aqbq;
            product_aqbq_t1 <= product_aqbq_t;
            product_aqbq_t2 <= product_aqbq_t1;
            product_aqbq_t3 <= product_aqbq_t2;

            sum_i <= product_aibi_t3 - product_aqbq_t3;
            if_i <= sum_i;



            product_aibq <= ($signed(t_rf_i) * $signed(t_lo_q));
            product_aibq_t  <= product_aibq;
            product_aibq_t1 <= product_aibq_t;
            product_aibq_t2 <= product_aibq_t1;
            product_aibq_t3 <= product_aibq_t2;
            product_aqbi <= ($signed(t_rf_q) * $signed(t_lo_i));
            product_aqbi_t  <= product_aqbi;
            product_aqbi_t1 <= product_aqbi_t;
            product_aqbi_t2 <= product_aqbi_t1;
            product_aqbi_t3 <= product_aqbi_t2;

            sum_q <= product_aibq_t3 + product_aqbi_t3;
            if_q <= sum_q;
        end

        end
    end
endmodule
