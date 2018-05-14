function var1 = unfrencry(pix, h, z0, nom, path)

% ���������� :

% h : ����� ����� (mm);
% Ih : ����������;
% L : ������ ���������� (mm);
% L0 : ������ ������� (mm);
% z0 : ���������� �� ������� (mm);

% ��������� � Matlab �����������

I1=imread(path);

% ����������� ������� ����������� � ������ double

Ih1=double(I1);

% ���������� ����������� ��������� ��� �������� ����������

k=2*pi/h;
[N1,N2]=size(Ih1);
N=min(N1,N2);
Ih=Ih1(1:N,1:N)-mean2(Ih1(1:N,1:N));
L=pix*N;
pg = 0;

if pg==1
    fm=filter2(fspecial('average',3),Ih);
    Ih=Ih-fm;
end

% �������������� ����������

n=-N/2:N/2-1;
x=n*pix;
y=x;
[xx,yy]=meshgrid(x,y);
Fresnel=exp(1i*k/2/z0*(xx.^2+yy.^2));

f2=Ih.*Fresnel;

Uf=fft2(f2,N,N);

Uf=fftshift(Uf);

ipix=h*abs(z0)/N/pix;

xi=n*ipix;

yi=xi;

figure;
imagesc(xi,yi,abs(Uf).^0.75);
colormap(gray);
axis equal;
axis tight;

title('Click on the upper-left and lower-right corner of the object');

XY=ginput(2);

% ���������� ������ � ������ �������

xc=0.5*(XY(1,1)+XY(2,1));
yc=0.5*(XY(1,2)+XY(2,2));
DAX=abs(XY(1,1)-XY(2,1));
DAY=abs(XY(1,2)-XY(2,2));

% ������������� � ������������� ������������� ����������

Gyi=min(L/DAX,L/DAY);
Gy=Gyi;
zi=-Gy*z0;
zc=1/(1/z0+1/zi);

% ���������� ����������� �����

sphere=exp(1i*k/2/zc*(xx.^2+yy.^2));

% ��������� ���������� ����������� ������

% ������� ����������, ���������� �� ����������� �����

f=Ih.*sphere;
TFUf=fftshift(fft2(f,N,N));

% ������������ �����

du=1/pix/N;
dv=du;

fex=1/pix;fey=1/pix;

fx=[-fex/2:fex/N:fex/2-fex/N];
fy=[-fey/2:fey/N:fey/2-fey/N];

[FX,FY]=meshgrid(fx,fy);

% ���������������� ������� ������� �����

Ur=xc/h/abs(z0);

Vr=yc/h/abs(z0);

% ������������ �������

Du=abs(Gy*DAX/h/zi);
Dv=abs(Gy*DAY/h/zi);

Gf=zeros(size(f));

Ir=find(abs(FX-Ur) < Du/2 & abs(FY-Vr) < Dv/2);

Gf(Ir)=exp(-1i*k*zi*sqrt(1-(h*(FX(Ir)-Ur)).^2-(h*(FY(Ir)-Vr)).^2));

% �������������� �����������

if sign(z0) == -1
    U0=fft2(TFUf.*Gf,N,N);
elseif sign(z0) == +1    
    U0=ifft2(TFUf.*Gf,N,N);
end

Gmax=max(max(abs(U0).^0.75));

Gmin=min(min(abs(U0).^0.75));

p=1;

while isempty(p) == 0
    
    IMAG = abs(U0).^0.75;
    
    p=0;
    
    if p==0
        break
        
    end
    
end

imwrite(IMAG/30,nom);

var1 = IMAG;
end