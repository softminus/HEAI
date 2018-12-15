`default_nettype none


module multirate_strobe (
    input wire  clock,
    input wire  slow_strobe,
    output wire fast_strobe
);

    reg lockout;
    assign fast_strobe = (slow_strobe) & (~lockout);

    always @ (posedge clock) begin
        lockout <= slow_strobe;
    end

endmodule // multirate_strobe