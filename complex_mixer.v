`default_nettype none
module complex_mixer (clock, clk_en, rf_i, rf_q, lo_i, lo_q, if_i, if_q);
    input [4:0] rf_i;
    input [4:0] rf_q;

    input [4:0] lo_i;
    input [4:0] lo_q;


    output reg [9:0] if_i;
    output reg [9:0] if_q;

    reg [4:0] t_rf_i;
    reg [4:0] t_rf_q;

    reg [4:0] t_lo_i;
    reg [4:0] t_lo_q;

    reg [9:0] product_aibi;
    reg [9:0] product_aqbq;

    reg [9:0] product_aibq;
    reg [9:0] product_aqbi;

    reg [9:0] product_aibi_t;
    reg [9:0] product_aqbq_t;
    reg [9:0] product_aibq_t;
    reg [9:0] product_aqbi_t;

    reg [9:0] product_aibi_t1;
    reg [9:0] product_aqbq_t1;
    reg [9:0] product_aibq_t1;
    reg [9:0] product_aqbi_t1;

    reg [9:0] product_aibi_t2;
    reg [9:0] product_aqbq_t2;
    reg [9:0] product_aibq_t2;
    reg [9:0] product_aqbi_t2;

    reg [9:0] product_aibi_t3;
    reg [9:0] product_aqbq_t3;
    reg [9:0] product_aibq_t3;
    reg [9:0] product_aqbi_t3;

    reg [9:0] sum_i;
    reg [9:0] sum_q;

    input wire clock;
    input wire clk_en;

    always @ (posedge clock) begin
        if (clk_en == 1) begin
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
endmodule
