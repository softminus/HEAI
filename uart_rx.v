`default_nettype none
// Blink an LED provided an input clock
/* module */
module top (hwclk, uart_rx, uart_mirror, debug_pin, led0, led1, led2, led3, led4, led5, led6, led7 );
    /* I/O */
    output led0;
    output led1;
    output led2;
    output led3;
    output led4;
    output led5;
    output led6;
    output led7;



    input hwclk;
    input uart_rx;
    output debug_pin;
    output uart_mirror;

    assign uart_mirror = uart_rx;


    localparam divisor = 26;
    localparam reload = divisor - 1;

    /* clock registers */
    reg [7:0] counter = 0;  /* runs at 12MHz from 0 to 255 */
    reg [1:0] subcount = 0; /* runs at 115200 * 4 from 0 to 3 */

    /* state */

    reg [1:0] samples = 0;  
    
    reg [3:0] bitcount = 0; /* number of bits so far, *including* start/stop bits, also an index into the shift register */
    reg [9:0] shiftreg = 0;

    reg voted_bit = 0;
    reg start_detected = 0;
    reg goodbyte = 0;

/*     reg [7:0] rx_count = 0; */




    reg resetn = 0;


    always @ (posedge hwclk) begin
        if (resetn == 0) 
        begin
            counter <= reload;
            resetn <= 1;
        end else begin
            counter <= counter - 1;
            debug_pin <= 0;

            if (counter == 0) begin /* stuff inside here executes at 4* baud */
                counter <= reload;
                subcount <= subcount + 1;


                if ((uart_rx == 0) && (start_detected == 0)) begin
                    start_detected <= 1;
                    subcount <= 0;
                    bitcount <= 0;
                end

                if (start_detected == 1) begin
                    if (subcount == 1) begin
                        voted_bit <= uart_rx;
                    end
                end


                if ((start_detected == 1) && (subcount == 2)) begin /* executes at baud rate */
//                    case (samples)
//                        2'b00: voted_bit <= 0;
//                        2'b01: voted_bit <= 1;
//                        2'b10: voted_bit <= 0;
//                       2'b11: voted_bit <= 1;
//                    endcase
                    
                    case (bitcount)
                        0: begin
                            if (voted_bit == 0) begin
                            bitcount <= bitcount + 1;
                        end
                        end

                        1,2,3,4,5,6,7,8: begin
                            shiftreg <= {shiftreg, voted_bit};
                            bitcount <= bitcount + 1;
                        end



                        9: begin 
                        if (voted_bit == 1) begin /* good stop bit, this is a complete byte */
                            goodbyte <= 1;
                            bitcount <= 0;
                            start_detected <= 0;
                        end else begin /* bad stop bit */
                            goodbyte <= 0; 
                            bitcount <= 0;
                            start_detected <= 0;
                        end
                    end

                    endcase



                    end /* baud rate */




                    /* note, this is to be executed non-conditionally */
                    if (goodbyte == 1) begin
                    led0 <= shiftreg[1];
                    led1 <= shiftreg[2];
                    led2 <= shiftreg[3];
                    led3 <= shiftreg[4];
                    led4 <= shiftreg[5];
                    led5 <= shiftreg[6];
                    led6 <= shiftreg[7];
                    led7 <= shiftreg[8];
                end



            end /* 4*baud period */
        end /* hwclock period */
    end /* begin */
endmodule

