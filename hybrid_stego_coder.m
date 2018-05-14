%
% Реализация комбинированного стеганографического метода
% Использование цифровой голограммы Фурье и алгоритм Кокса
% 
%

format compact;
clear;

% Чтение исходного изображения
source = imread('img.bmp');

% Задание угла падения и фазы пучка света
theta = 0.45;
phi = 0.3;
% Задание коэффициента встраивания
alpha = 0.9;

% Определение размера контейнера
[h, w, ~] = size(source);
% Создание матрицы для последующей модификации
modifiedM = zeros(h, w);
for i = 1:h
  for j = 1:w
    modifiedM(i,j) = source(i, j, 1) / 3 + source(i, j, 2) / 3 + source(i, j, 3) / 3;
  end
end
% imshow(modifiedImg, [0, 255])

% Получение голограммы Фурье
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

% % Чтение изображения ЦВЗ
% watermark = imread('message.jpg');
% 
% % Преобразование для встраивания по алгоритму Кокса
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
% % Встраивание в AC-коэффициенты голограммы
% modifiedM = hologram;
% for i = 0:messageLen
%   [value, r] = max(hologram);
%   [value, c] = max(value);
%   r = r(c);
%   hologram(r, c) = 0;
%   % Пропуск DC-коэффициента
%   if i ~= 0
%     modifiedM(r, c) = value * exp(alpha * message(1, i));
%   end
%   % Вывод голограммы на экран
%   if i == 1
%     imshow(abs(modifiedM / value));
%   end
% end
% 
% % Восстановление изображения из голограммы без цветовой информации
% result = uint8(abs(ifft2(modifiedM * exp(2 * pi * 1i * theta) + exp(2 * pi * 1i * phi))));
% 
% %  Запись результата в файл
% % imshow(result, [0, 255]);
% imwrite(cat(3, result, result, result), 'stego_image.jpg');
