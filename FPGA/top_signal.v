module top_signal (
    input clk,
    output [13:0] signal_output 
);
wire [6:0] address_bus;

sg_driver sg_driver (.clk(clk), .address(address_bus));

signal_generator signal_gen (.clock(clk), .address(address_bus), .q(signal_output));

endmodule