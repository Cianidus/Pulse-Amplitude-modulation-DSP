
module mov_av (
    input clk,  
    input [76:0] in,  //вход
    output reg [20:0] period, //Время между импульсами 
    output reg time_point, //Отметка времени между импульсами
    output reg phase_mark, //Фазовая отметка
    output reg [9:0] phase_time //Фаза
);

reg [76:0] mov_window [15:0]; //Окно скользящего среднего
integer i, n;

initial 
begin
    period = 0;
    time_point = 0;
    phase_mark = 0;
    for (i = 0; i < 15; i=i+1)
        mov_window[i] = 0;
end

always @(posedge clk)
begin
    for (n = 15; n > 0; n=n-1) begin //Передвижение окна по отчетам сигнала
        mov_window[n] = mov_window[n-1];
        mov_window[0] = in; 
    end  
end
//Формирование скользящего окна
wire [76:0] ch1;
wire [76:0] ch2;
wire [76:0] ch3;
wire [76:0] ch4;
wire [76:0] ch5;
wire [76:0] ch6;
wire [76:0] ch7;
wire [76:0] ch8;
wire [76:0] ch9;
wire [76:0] ch10;
wire [76:0] ch11;
wire [76:0] ch12;
wire [76:0] ch13;
wire [76:0] ch14;
wire [76:0] ch15;
wire [76:0] ch16;

assign ch1 = mov_window[0];
assign ch2 = mov_window[1];
assign ch3 = mov_window[2];
assign ch4 = mov_window[3];
assign ch5 = mov_window[4];
assign ch6 = mov_window[5];
assign ch7 = mov_window[6];
assign ch8 = mov_window[7];
assign ch9 = mov_window[8];
assign ch10 = mov_window[9];
assign ch11 = mov_window[10];
assign ch12 = mov_window[11];
assign ch13 = mov_window[12];
assign ch14 = mov_window[13];
assign ch15 = mov_window[14];
assign ch16 = mov_window[15];

wire [77:0] sr; //Среднее арифметическое

assign sr = (ch1+ch2+ch3+ch4+ch5+ch6+ch7+ch8+ch9+ch10+ch11+ch12+ch13+ch14+ch15+ch16) << 4; // Т.к размер окна является степенью 2, деление заменяем сдвигом

reg [76:0] acc [2:0]; //Аккумулятор, хранящий три отсчета среднего: прошлый отчет, текущий и будущий

always @(posedge clk)
begin
    acc[2] <= acc[1];
    acc[1] <= acc[0];
    acc[0] <= sr;
end
/////////////////////////////////////////////////////////////////////////////

localparam wait_pulse = 0, first_pulse = 1;
reg state;
reg [20:0] timer = 0; 
reg start_timer = 0; //Флаг старта счета таймера
reg time_mark = 0; //Временная отметка

/////////////////////////////////////////////////////////////////////////////
//Вычисление времени между импульсами
always @(posedge clk)
begin
    case (state)
    wait_pulse: begin
        time_mark <= 0;
        if (acc[1] > acc[0] && acc[1] > acc[2]) begin //Нахождение первого экстремума
            state <= first_pulse;
        end
        else
            state <= wait_pulse;
    end
    first_pulse: begin        
        if (acc[1] > acc[0] && acc[1] > acc[2]) begin //Нахождение второго экстремума
            begin
                time_mark <= 1; //Временая отметка
                state <= wait_pulse;   
            end            
        end
        else
            state <= first_pulse;
    end
    default : state <= wait_pulse;
    endcase
end

reg [1:0] cnt_time_mark = 0; //Счетчик временных отметок

always @(posedge clk) //Подсчет времени между каждой второй временной отметкой
begin
    if(time_mark)
        cnt_time_mark <= cnt_time_mark+1;
    if(cnt_time_mark == 2) begin
        if (timer != 0) begin
            period <= timer;
            time_point <= 1;
            start_timer <= 0;
        end
        else begin
            start_timer <= 1;       
            time_point <= 0;
            cnt_time_mark <= 0;
        end
    end
end
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
//Вычисление фазы

always @(posedge clk) 
begin
    if(start_timer) timer <= timer+1;
    else timer<=0;
end

reg start_phase_timer = 0; //Флаг старта счета таймера
reg [77:0] max; //Значение максимума
wire [77:0] norm_max_high;
wire [77:0] norm_max_low;
assign norm_max_high = max*0.61; //Верхняя граница интервала
assign norm_max_low = max*0.59; //Нижняя граница интервала
wire [81:0] amplitude;
assign amplitude = sr; //Текущая амплитуда
reg [9:0] phase_timer = 0; 

always @(posedge clk)
begin
    if (time_mark) begin //Пользуемся временной отметкой экстремума
        max <= acc[1];
        start_phase_timer <= 1; //Начинаем считать 
    end
    if(amplitude > norm_max_low && amplitude < norm_max_high) begin //Если попали в заданный интервал, создали отметку            
        start_phase_timer <= 0;
        phase_mark <= 1;
        max<=0;
    end
    else phase_mark <= 0;
end

always @(posedge clk) 
begin
    if(start_phase_timer) begin //Запускаем таймер по флагу
        phase_timer <= phase_timer+1;
    end 
    else begin //Защелкнули значение таймера на выход 
        phase_time<=phase_timer;
        phase_timer<=0;
    end 
end
/////////////////////////////////////////////////////////////////////////////
endmodule