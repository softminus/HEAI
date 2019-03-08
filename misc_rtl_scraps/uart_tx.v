// Blink an LED provided an input clock
/* module */
module top (hwclk, uart_rx, uart_tx, mirror_tx);
    /* I/O */
    input hwclk;
    input uart_rx;
    output uart_tx;
    output mirror_tx;

    assign mirror_tx = uart_tx;

    /* Counter register */
    reg [7:0] counter = 0;
    reg [1:0] subcount = 0;
    
    reg [3:0] bitcount = 0;
    reg [9:0] shift = 0;
    reg [7:0] curbyte = 0;
    reg [95:0] fifo = 0;
    reg [7:0] bytecount = 0;


    localparam divisor = 26;
    localparam reload = divisor - 1;

    localparam string = 96'h6865_6c6c_6f20_776f_726c_640a;


    reg resetn = 0;


    always @ (posedge hwclk) begin
        if (resetn == 0) 
        begin
            counter <= reload;
            resetn <= 1;
        end else begin
            counter <= counter - 1;

            if (counter == 0) begin
                counter <= reload;
                subcount <= subcount + 1;
                if (subcount == 0) begin
                    /* this executes at baud period */

                    bitcount <= bitcount + 1;
                    shift <= {1'b1, shift[9:1]};

                    if (bitcount == 0) begin

                        bytecount <= bytecount + 1;
                        if (bytecount == 12) begin
                            bytecount <= 0;
                            fifo <= string;
                        end else begin

                        curbyte <= fifo[95:88];
                        fifo <= fifo << 8;
                        shift <= {1'b1, curbyte, 1'b0};
                    end
                    end else if (bitcount == 15) begin
                        bitcount <= 0;
                    end

                    uart_tx <= shift[0];

                end  
            end


        end
    end

endmodule

