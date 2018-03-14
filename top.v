`default_nettype none
/* module */
module top (rx_clock, leds);
    /* I/O */
    input rx_clock;
    wire pll_clock;

    output reg [7:0] leds;
    wire [3:0] sins;

    reg [20:0] bigcount = 0;
    pll chip_pll(rx_clock, pll_clock);
    nco sin(pll_clock,3 ,  sins);



    always @(posedge pll_clock) begin
        bigcount <= bigcount + 1;
   //     if (bigcount == 1) begin
            leds[7:4] <= sins;
 //      end

    end




endmodule

