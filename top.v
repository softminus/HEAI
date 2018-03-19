`default_nettype none
/* module */
module top (rx_clock, leds, debugport);
    /* I/O */
    input rx_clock;
    wire pll_clock;

    wire clk_en;

    output reg [7:0] leds;
    output reg [7:0] debugport;

    wire [3:0] sins;
    wire [3:0] cosines;

    reg [24:0] bigcount = 0;

    pll chip_pll(rx_clock, pll_clock);
    nco sin(pll_clock, clk_en, 3 ,  sins, cosines);


//    assign clk_en = (bigcount == 0);
    assign clk_en = 1;

    assign debugport[0] = pll_clock;
    always @(posedge pll_clock) begin
        bigcount <= bigcount + 1;
        leds[7:4] <= sins;
        leds[3:0] <= cosines;
        debugport[7:4] <= sins;
    end




endmodule

