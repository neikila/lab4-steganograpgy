function var = frencry(h, L, z0,nom,path)

% ���������� :
% h : ����� ����� (mm);
% Ih : ����������;
% L : ������ ���������� (mm);
% L0 : ������ ������� (mm);
% z0 : ���������� �� ������� (mm);

% ��������� � Matlab �����������

[XRGB,~]=imread(path);

% �������� ������� ������������ �����������

X=double(XRGB(:,:,1));

%���������� ������ �����������

[M,N]=size(X);

% ���������� ������������ ������� �����������

K=2*max(N,M) ;

% ������ ��������������� �������

Z1=zeros(K,(K-N)/2);
Z2=zeros((K-M)/2,N);

% ��������� ���������� ���������������� ���������

Obj=[Z1,[Z2;X;Z2],Z1];

% ���������� ����������� ��������� ��� �������� ����������

k=2*pi/h;
pix=abs(z0)*h/L;
Lx=K*pix;
Ly=K*pix;

% ������ ��������� ����

psi=2*pi*(rand(K,K)-0.5);

% ����������� ������� �����������

Ao=Obj.*exp(1i.*psi);

% Complex factor in the integral

n=-K/2:K/2-1;
m=-K/2:K/2-1;

x=n*pix;
y=m*pix;

[xx,yy]=meshgrid(x,y);

Fresnel=exp(1i*k/2/z0 * (xx.^2 + yy.^2));

f2=Ao.*Fresnel;

% ���������� ������� ������ �� ������� ���

Uf=fft2(f2,K,K);

Uf=fftshift(Uf);

% ��� � ��������� ������������

ipix=h*abs(z0)/K/pix;

xi=n*ipix;
yi=m*ipix;

L0x=K*ipix;
L0y=K*ipix;

[xxi,yyi]=meshgrid(xi,yi);

phase=exp(1i*k*z0)/(1i*h*z0) * exp(1i*k/2/z0*(xxi.^2+yyi.^2));

Uf=Uf.*phase;

% �������� ������� �����

% ���������������� �������

ur=Lx/8/h/z0;

vr=ur;

% ��������� ������� �����

Ar=max(max(abs(Uf)));

% ������� �����

Ur=Ar*exp(2*1i*pi*(ur*xx+vr*yy));

% ���������� ����� ����������

H=abs(Ur+Uf).^2;

% 8�� ������ ���������

Imax=max(max(H));

Ih=uint8(255*H/Imax);

% ������ ���������� �� ����

imwrite(Ih,nom);

var = ipix;
end
