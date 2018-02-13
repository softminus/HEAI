`default_nettype none
/* module */
module spi_master (
    input clk,

    input write,            /* 1 if this is a write transaction, 0 if not */
    input [7:0] data_in,    /* data to write */
    input [6:0] address,    /* where to read/write */
    input strobe,           /* poke to initiate SPI transaction */
    output read_data_valid, /* is 1 iff a read transaction has completed and data_out is valid */
    output [7:0] data_out,
    output busy,
    
    /* spi pins */
    output cs,
    output sclk,
    output mosi,
    input miso);


    localparam clock_divisor = 32;

/*    sample on high clock (rising clock?)
    change on low clock */


    always @ (posedge clk) begin


    end /* begin */
endmodule

