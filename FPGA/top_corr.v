module top_corr (
    input clk,
    output [76:0] corr_factor,
    output [20:0] period,
    output time_point,
    output [9:0] phase_time,
    output phase_mark 
);
wire [13:0] signal_bus;

top_signal gen_signal (.clk(clk), .signal_output(signal_bus));

fir xcross_inst (     .clk(clk),
                      .in(signal_bus), 
                      .out(corr_factor)
                      );

mov_av mov_av_inst (.clk(clk), 
                    .in(corr_factor), 
                    .period(period), 
                    .time_point(time_point),
                    .phase_time(phase_time),
                    .phase_mark(phase_mark)
                    );

endmodule 