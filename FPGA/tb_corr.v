`timescale 1 ns / 1 ns

module tb_corr ();
reg clk;
wire [76:0] corr_factor;
wire [20:0] period;
wire time_point;
wire [9:0] phase_time;
wire phase_mark;

top_corr top_corr (.clk(clk), 
                .corr_factor(corr_factor),
                .period(period),
                .time_point(time_point),
                .phase_time(phase_time),
                .phase_mark(phase_mark)
                );


always @(posedge clk) begin
    if(time_point)
    $display("The period between two pulses equal is %d",  period/1000, "ms");
end


always @(negedge phase_mark) begin
    $display("The phase between max amplitude and 0.6 amplitude equal is %d",  phase_time, "us");
end

always
    #500 clk = !clk;
initial 
begin
    clk = 0;
end 


endmodule