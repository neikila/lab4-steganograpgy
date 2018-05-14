function var = frencry(h, L, z0,nom,path)

% Переменные :
% h : длина волны (mm);
% Ih : голограмма;
% L : ширина голограммы (mm);
% L0 : ширина объекта (mm);
% z0 : расстояние до объекта (mm);

% Загружаем в Matlab Изображение

[XRGB,~]=imread(path);

% Выбираем красную составляющую изображения

X=double(XRGB(:,:,1));

%Определяем размер изображения

[M,N]=size(X);

% Определяем максимальную сторону изображения

K=2*max(N,M) ;

% Создаём вспомогательные массивы

Z1=zeros(K,(K-N)/2);
Z2=zeros((K-M)/2,N);

% Дополняем зображение вспомогательными массивами

Obj=[Z1,[Z2;X;Z2],Z1];

% Определяем необходимые параметры для создания голограммы

k=2*pi/h;
pix=abs(z0)*h/L;
Lx=K*pix;
Ly=K*pix;

% Создаём случайную фазу

psi=2*pi*(rand(K,K)-0.5);

% Комплексная область изображения

Ao=Obj.*exp(1i.*psi);

% Complex factor in the integral

n=-K/2:K/2-1;
m=-K/2:K/2-1;

x=n*pix;
y=m*pix;

[xx,yy]=meshgrid(x,y);

Fresnel=exp(1i*k/2/z0 * (xx.^2 + yy.^2));

f2=Ao.*Fresnel;

% Дополнения массива нулями до размера КхК

Uf=fft2(f2,K,K);

Uf=fftshift(Uf);

% Шаг в плоскости регистратора

ipix=h*abs(z0)/K/pix;

xi=n*ipix;
yi=m*ipix;

L0x=K*ipix;
L0y=K*ipix;

[xxi,yyi]=meshgrid(xi,yi);

phase=exp(1i*k*z0)/(1i*h*z0) * exp(1i*k/2/z0*(xxi.^2+yyi.^2));

Uf=Uf.*phase;

% Создание опорной волны

% Пространственные частоты

ur=Lx/8/h/z0;

vr=ur;

% Амплитуда опорной волны

Ar=max(max(abs(Uf)));

% Опорная волна

Ur=Ar*exp(2*1i*pi*(ur*xx+vr*yy));

% Вычисление самой голограммы

H=abs(Ur+Uf).^2;

% 8ми битная оцифровка

Imax=max(max(H));

Ih=uint8(255*H/Imax);

% Запись голограммы на диск

imwrite(Ih,nom);

var = ipix;
end
