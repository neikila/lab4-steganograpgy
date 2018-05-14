%
% ���������� ���������������� ������������������� ������
% ������������� �������� ���������� ����� � �������� �����
% 
%

format compact;
clear;

% ������ ��������� �����������
source = imread('img.bmp');

% ������� ���� ������� � ���� ����� �����
theta = 0.45;
phi = 0.3;
% ������� ������������ �����������
alpha = 0.9;

% ����������� ������� ����������
[h, w, ~] = size(source);
% �������� ������� ��� ����������� �����������
modifiedM = zeros(h, w);
for i = 1:h
  for j = 1:w
    modifiedM(i,j) = source(i, j, 1) / 3 + source(i, j, 2) / 3 + source(i, j, 3) / 3;
  end
end
% imshow(modifiedImg, [0, 255])

% ��������� ���������� �����
fourier = fftshift(fft2(modifiedM)) * exp(2 * pi * 1i * theta);
fourier = fourier + exp(2 * pi * 1i * phi);

hologram = fourier * exp(2 * pi * 1i * theta);

% [value, r] = max(hologram);
% [~, c] = max(value);
% r = r(c);
% temp = hologram(r, c);
% hologram(r, c) = 0;
% [value, ~] = max(hologram);
% [value, ~] = max(value);
% hologram(r, c) = temp;
% holAbs = abs(hologram / value);
% imshow(holAbs);

result = uint8(abs(ifft2(hologram* exp(2 * pi * 1i * theta) + exp(2 * pi * 1i * phi))));
result - modifiedM;

% imshow(result);

% % ������ ����������� ���
% watermark = imread('message.jpg');
% 
% % �������������� ��� ����������� �� ��������� �����
% [h, w, c] = size(watermark);
% message = zeros(1, w * h);
% for i = 1:h
%   for j = 1:w
%     message(1, (i - 1) * w + j) = watermark(i, j, 1);% / 3 %+ watermark(i, j, 2) / 3 + watermark(i, j, 3) / 3
%   end
% end
% message = 0.5 - message / 255;
% messageLen = w * h;
% 
% % ����������� � AC-������������ ����������
% modifiedM = hologram;
% for i = 0:messageLen
%   [value, r] = max(hologram);
%   [value, c] = max(value);
%   r = r(c);
%   hologram(r, c) = 0;
%   % ������� DC-������������
%   if i ~= 0
%     modifiedM(r, c) = value * exp(alpha * message(1, i));
%   end
%   % ����� ���������� �� �����
%   if i == 1
%     imshow(abs(modifiedM / value));
%   end
% end
% 
% % �������������� ����������� �� ���������� ��� �������� ����������
% result = uint8(abs(ifft2(modifiedM * exp(2 * pi * 1i * theta) + exp(2 * pi * 1i * phi))));
% 
% %  ������ ���������� � ����
% % imshow(result, [0, 255]);
% imwrite(cat(3, result, result, result), 'stego_image.jpg');
