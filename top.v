`default_nettype none
/* module */
module top (crystal, debug_pin, txd_full, tx_clock, iqsel);
    /* I/O */
    output wire [11:0] txd_full;
    input tx_clock;
    output iqsel;

    wire chipclock;

    input crystal;
    output wire debug_pin;


    reg rst = 0;
    reg tx_ready;

    pll chip_pll(crystal, chipclock);

    wire [23:0] tx_data_i;


    lms6_tx lms (rst, chipclock, tx_data_i, tx_ready, txd_full, iqsel);

    assign debug_pin = txd_full[0];


    reg [1:0] memory[0:2047];
    initial $readmemh("modea.hex", memory);


    function [23:0] iq_expand;
        input [1:0] small;
        case (small)
            2'b00: iq_expand = 24'h000000;
            2'b01: iq_expand = 24'h000fff;
            2'b10: iq_expand = 24'hfff000;
            2'b11: iq_expand = 24'hffffff;
        endcase
    endfunction


    reg [23:0] bigcount = 0;
    reg enable;
    reg [10:0] counter =0 ;
    always @(posedge chipclock) begin
        bigcount <= bigcount + 1;
        
        if (bigcount == 0) begin
            enable <= 1;
        end

        if (enable == 1) begin
            counter <= counter + 1;
            tx_data_i <= iq_expand(memory[counter]);
        end
        if (counter == 2047) begin
            enable <= 0;
        end



    end




endmodule

