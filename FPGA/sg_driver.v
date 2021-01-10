module sg_driver (
    input clk, 
    output reg [6:0] address //Адрес памяти
);

initial 
begin
    address = 0;
end

localparam pulse = 0, small_interval = 1, big_interval = 2;

reg [10:0] time_between_pulses = 18'h7D0; //2ms
reg [16:0] period = 17'h186A0; //100ms
reg two_pulses;
reg [1:0] state;

//Формирование сигнала из ТЗ
always @(posedge clk)
begin
    case (state)
        pulse: begin
            address <= address+1;
            if (address == 7'd100) begin
                address <= 0;
                if (two_pulses)
                    state <= big_interval;
                else
                    state <= small_interval;
            end
        end
        small_interval: begin
            time_between_pulses <= time_between_pulses-1;
            two_pulses <= 1;
            if (time_between_pulses == 0) begin
                time_between_pulses <= 18'h7D0;
                state <= pulse;           
            end
        end
        big_interval: begin
            period <= period-1;
            two_pulses <= 0;
            if (period == 0) begin
                period <= 24'h186A0;
                state<=pulse;              
            end
        end
        default : begin 
            state <= pulse;
            two_pulses <= 0;
        end
    endcase
end

endmodule