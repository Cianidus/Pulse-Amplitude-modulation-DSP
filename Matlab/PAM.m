clc
clear all
Fs = 1e6; %Частота дескритизации
Ts = 1/Fs;
dt = 0:Ts:2e-2-Ts;

Fc = 1e5; %Частота несущей
dutycycle = 50;
s = square(2*pi*Fc*dt,dutycycle); %Формирование прямоугольных импульсов
s(find(s<0))=0;

Fm = 5e3; %Частота модулирующего сигнала
t = sawtooth(2*pi*Fm*dt, 1/2); %Формирование треугольных импульсов
t(find(t<0))=0;

%////////////////////////////////////////////////////////////////////
%///////////Формирование модулирующего сигнала из ТЗ////////////////
triangle_pulse(1:100) = t(51:150);
double_pulse(51:150) = triangle_pulse;
double_pulse(2001:2100) = triangle_pulse;
pulses = zeros(1,2e4);
pulses(1:2100) = double_pulse;
pulses(1e4+1:1e4+2100) = double_pulse;
%////////////////////////////////////////////////////////////////////

%////////////////////////////////////////////////////////////////////
%/////////////Амплитудно-импульсная модуляция///////////////////////
period_sam = length(dt)/2000;     
ind = 1:period_sam:length(dt);   
on_samp = ceil(period_sam * dutycycle/100);  
pam = zeros(1,length(dt)); %Модулированный сигнал

for i =1:length(ind)
    pam(ind(i):ind(i)+on_samp) = pulses(ind(i));
end 
%////////////////////////////////////////////////////////////////////

%////////////////////////////////////////////////////////////////////
%//////////Нахождение спектра PAM сигнала////////////////////////////
lg_fft = length(pam);
norm_lg_fft = 2.^nextpow2(lg_fft); %нормируем кол-во отсчетов до степени 2
fft_pam = fft(pam,norm_lg_fft);
fft_pam = fft_pam(1:norm_lg_fft/2);
xfft=Fs.*(0:norm_lg_fft/2-1)/norm_lg_fft; %спектрограмма PAM-signal
%////////////////////////////////////////////////////////////////////

cut_off=1e5/Fs/2;
order = 16;
h=fir1(100, 0.15);
con=conv(pam,h);

%////////////////////////////////////////////////////////////////////
%//Находим коэффициент корреляции и в момент максимума запоминаем
%//временную отметку////////////////////////////////////////////////
koeff = zeros(1, length(pam)); %Коэффициент коррелляции
temp = zeros(1, 100);
time = zeros(1, length(pam));
time_point = zeros(1,2); %Массив временных отметок
k = 0;
ptr = 1;
for i =1:length(pam)  
    temp(length(temp)) = pam(i); %Окно, скользящее по массиву отчетов 
    temp = circshift(temp, -1);
    [acor,lag] = xcorr(temp, triangle_pulse); %Расчет корреляции между окном и эталонным сигналом
    koeff(i) = max(acor)/20; %Нормируем коэффициент
    if i > 1 && i < length(pam)
        if koeff(i) > 1 
            if k == 0
                time(i) = 1;
                time_point(ptr) = i;
                ptr = ptr+1;
                k = 1;
            end
        else 
            k = 0;
        end
    end
end

period = (time_point(3)-time_point(2))/1e6; %Находим разницу между 3й и 2й отметкой

% subplot(2,1,1);
% plot(xfft, abs(fft_pam/max(fft_pam)));
% subplot(2,1,2);
% plot(con);


subplot(4,1,1);
plot(dt, pulses);
ylim([-1 2]);
subplot(4,1,2);
plot(dt, pam);
ylim([-1 2]);
subplot(4,1,3);
plot(dt, koeff);
ylim([-1 2]);
subplot(4,1,4);
plot(dt, time);
ylim([0 2]);
