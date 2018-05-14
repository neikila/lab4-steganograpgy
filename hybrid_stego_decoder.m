%
% Реализация комбинированного стеганографического метода
% Использование цифровой голограммы Фурье и алгоритм Кокса
% 
%

format compact;
clear;

% Чтение контейнера
stego = imread('stego_image.jpg');

% Задание угла падения и фазы пучка света
theta = 0.45;
phi = 0.3;
% Задание размеров водяного знака
width = 50;
hight = 29;
% Задание коэффициента встраивания
alpha = 0.9;

% Определение размера контейнера
[w, h, ~] = size(stego);
% Создание матрицы по одному каналу
modifiedM = zeros(w, h);
for i = 1:w
  for j = 1:h
    modifiedM(i,j) = stego(i, j, 1);
  end
end
% imshow(modifiedM, [0,255])

% Получение голограммы Фурье
fourier = fftshift(fft2(modifiedM)) * exp(2 * pi * 1i * theta);
fourier = fourier + exp(2 * pi * 1i * phi);
hologram = fourier * exp(2 * pi * 1i * theta);

% Чтение исходного изображения
source = imread('image.jpg');

% Определение размера
[w, h, c] = size(source);
% Создание матрицы по одному каналу
sourceM = zeros(w, h);
for i = 1:w
  for j = 1:h
    sourceM(i,j) = source(i, j, 1) / 3 + source(i, j, 2) / 3 + source(i, j, 3) / 3;
  end
end

% Получение голограммы Фурье исходного изображения
fourier = fftshift(fft2(sourceM)) * exp(2 * pi * 1i * theta);
fourier = fourier + exp(2 * pi * 1i * phi);
hologramSource = fourier * exp(2 * pi * 1i * theta);

% Получение разницы AC-коэффициентов голограмм
message = zeros(1, width * hight);
messageLen = width * hight;
for i = 0:messageLen
  [value, r] = max(hologramSource);
  [value, c] = max(value);
  r = r(c);
  hologramSource(r, c) = 0;
  if i == 1
    imshow(abs(hologram / value));
  end
  % Пропуск DC-коэффициента
  if i ~= 0
    difference = real(hologram(r, c) / value);
    message(1, i) =  1 / alpha * log(difference);
  end
end

% Восстановление водяного знака
watermark = zeros(hight, width, 'uint8');
for i = 1:hight
  for j = 1:width
    watermark(i, j) = uint8(255 * (0.5 - message(1, (i - 1) * width + j)));
  end
end

%  Запись восстановленного знака в файл
imshow(watermark, [0, 255]);
imwrite(cat(3, watermark, watermark, watermark), 'decoded_message.jpg');
