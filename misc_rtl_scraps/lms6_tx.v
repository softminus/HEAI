`default_nettype none
/* LMS6002D tx */
module lms6_tx (input rst, input clk, input [23:0] tx_data_i, output tx_ready, output [11:0] txd, output wire txiqsel);
    /* I/O */

    wire [11:0] txd_int;

    assign txd_int = txiqsel ? tx_data_i[11:0] : tx_data_i[23:12];
    assign tx_ready = txiqsel;


    reg txiqsel_int;

    always @(posedge clk) begin
        txiqsel <= txiqsel_int;
        txd <= txd_int;

        txiqsel_int <= !txiqsel_int;
        
        if (rst) begin
            txiqsel_int <= 1'b0;
        end


    end

endmodule
