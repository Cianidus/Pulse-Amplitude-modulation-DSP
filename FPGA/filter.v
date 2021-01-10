module fir (clk, in, out);

parameter IWIDTH = 14;	//Ширина входных данных
parameter CWIDTH = 14;	//tap coef data width (should be less then 32 bit)
parameter TAPS   = 50;	//Ширина импульсной характеристики
localparam MWIDTH = (IWIDTH+CWIDTH); //Ширина после умножения
localparam RWIDTH = (MWIDTH+TAPS-1); //Ширина выходных данных

input  wire clk; 
input  wire [IWIDTH-1:0]in; //Вход данных
output wire [RWIDTH-1:0]out; //Выход данных 

reg [13:0] h [50:0]; //Массив регистров для хранения весовых коэффициентов

//Инициализация весовых коэффициентов импульсной характеристики фильтра
initial 
begin
	h[0] = 120;
	h[1] = 240;
	h[2] = 360;
	h[3] = 480;
	h[4] = 600;
	h[5] = 720;
	h[6] = 840;
	h[7] = 960;
	h[8] = 1080;
	h[9] = 1200;
	h[10] = 1320;
	h[11] = 1440;
	h[12] = 1560;
	h[13] = 1680;
	h[14] = 1920;
	h[15] = 2040;
	h[16] = 2160;
	h[17] = 2280;
	h[18] = 2400;
	h[19] = 2520;
	h[20] = 2640;
	h[21] = 2760;
	h[22] = 2880;
	h[23] = 3000;
	h[24] = 3120;
	h[25] = 3240;
	h[26] = 3360;
	h[27] = 3480;
	h[28] = 3600;
	h[29] = 3720;
	h[30] = 3840;
	h[31] = 3960;
	h[32] = 4080;
	h[33] = 4200;
	h[34] = 4320;
	h[35] = 4440;
	h[36] = 4560;
	h[37] = 4680;
	h[38] = 4800;
	h[39] = 4920;
	h[40] = 5040;
	h[41] = 5160;
	h[42] = 5280;
	h[43] = 5400;
	h[44] = 5520;
	h[45] = 5640;
	h[46] = 5760;
	h[47] = 5880;
	h[48] = 6000;
	h[49] = 5880;
	h[50] = 5760;
end

genvar i;
generate
	for( i=0; i<TAPS; i=i+1 )
	begin:tap
		
		reg [IWIDTH-1:0]r=0; //Исходная цепь регистров
		if(i==0)
		begin
			always @(posedge clk)
				r <= in; //Присвоение первому регистру значение входа фильтра
		end
		else
		begin
			
			always @(posedge clk) //Сдвиг данных по регистрам
				tap[i].r <= tap[i-1].r;
		end

		
		wire [CWIDTH-1:0]c; //Генерация линий с весовыми коэффициентами
		assign c = h[i];


		reg [MWIDTH-1:0]m; 
		always @(posedge clk)
			m <= $signed(r) * $signed( c ); //Умножение входных данных и коэффициентов, с записью резльтата в регистр m
			

		reg [MWIDTH-1+i:0]a; //Генерация сумматоров
		if(i==0)
		begin
			always @*
				tap[i].a = $signed(tap[i].m);
		end
		else
		begin
			always @* //Генерация суммирование результатов умножения
				tap[i].a = $signed(tap[i].m)+$signed(tap[i-1].a);
		end
	end
endgenerate


reg [RWIDTH-1:0]result; //Защелкивание отфильтрованных данных 
always @(posedge clk)
	result <= tap[TAPS-1].a;


assign out = result; //Вывод отфильтрованных данных

endmodule