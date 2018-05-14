% clear
delete encoded*
delete restored*

format compact;

fileID = fopen('filetohide.txt');
data = fread(fileID);

delta = 3;
boxSize = 4;
filename = 'img.bmp';

% prepare
img = adjust(imread(filename), filename, boxSize);
img = asOne(img);

layer = img(:,:,1);

% create gollogramm
% «адание угла падени€ и фазы пучка света
theta = 0.45;
phi = 0.3;
hologram = getHologram(layer, theta, phi);

% encode message
layer = encodeImage(delta, boxSize, data, hologram);
% layer = hologram;

% restore img from hollogramm
layerRestored = ifft2(layer * exp(2 * pi * 1i * theta) + exp(2 * pi * 1i * phi));
% layer = uint8(abs(layerRestored));
% img(:,:,1)=layer;
% img(:,:,2)=layer;
% img(:,:,3)=layer;
% imshow(img);

% we got a container
% [img, encodedFilename] = saveEncoded(img, layer, filename);

% get hollagram from container
% theta = 0.45;
% phi = 0.3;
% hologram = getHologram(layer, theta, phi);
% layer = hologram;


% decode message
% img = imread(encodedFilename);
% blue = img(:,:,3);
result = decodeMsg(delta, length(data), layer, boxSize);
char(result)

fileID = fopen('restored_msg.txt','w');
fwrite(fileID, result);
fclose(fileID);


function hologram=getHologram(layer, theta, phi)
fourier = fftshift(fft2(layer)) * exp(2 * pi * 1i * theta);
fourier = fourier + exp(2 * pi * 1i * phi);
hologram = fourier * exp(2 * pi * 1i * theta);
end



function [img]=asOne(source)
[h, w, ~] = size(source);
modifiedM = zeros(h, w);
for i = 1:h
    for j = 1:w
        modifiedM(i,j) = source(i, j, 1) / 3 + source(i, j, 2) / 3 + source(i, j, 3) / 3;
    end
end
source(:,:,1)=modifiedM;
source(:,:,2)=modifiedM;
source(:,:,3)=modifiedM;
img = source;
end




function [result]=decodeMsg(delta, charsAmount, img, boxSize)
context.boxSize = boxSize;
context.delta = delta;
context.blue = img;

arr = size(context.blue) / context.boxSize;
context.maxXLimit = arr(2);

context.D = dctmtx(boxSize);

message = int8(zeros(1, charsAmount));
for i=1:charsAmount
    message(i) = decodeNum(i, context);
end
result = char(message);
end

function [num]=decodeNum(index, context)
num = 0;
bits = 8;
for i=1:bits
    blockIndex = bits * index + (i - 1);
    [y, x] = getBlockByIndex(blockIndex, context.maxXLimit);
    matrix = subSet(y, x, context.blue, context.boxSize);
    dct = matrixDct(matrix, context.D);
    bit = restoreBit(dct, context.delta);
    if bit == 1
        num = bitset(num, i);
    end
end
end

function [bit]=restoreBit(dct, delta)
[x1Encode, y1Encode] = getFirstIndexStub(size(dct, 1));
[x2Encode, y2Encode] = getSecondIndexStub(size(dct, 1));
diff = abs(dct(y1Encode, x1Encode)) - abs(dct(y2Encode, x2Encode));

if diff <= -delta
    bit = 1;
else
    bit = 0;
end
end

function [imageLayer]=encodeImage(delta, boxSize, data, img)
context.delta = delta;
context.boxSize = boxSize;

context.blue = img;

arr = size(context.blue) / context.boxSize;
context.maxXLimit = arr(2);
context.D = dctmtx(boxSize);

for i = 1:length(data)
    blueUpdated=encodeNum(data(i), i, context);
    context.blue = blueUpdated;
end

imageLayer = context.blue;
end

function [y, x]=getBlockByIndex(index, maxXLimit)
index = index - 1;
y = fix(index / maxXLimit) + 1;
x = mod(index, maxXLimit) + 1;
end

function [result]=encodeNum(num, numIndex, context)
bits = 8;
for i=1:bits
    bit=bitget(num, i);
    offset = i - 1;
    [y, x] = getBlockByIndex(bits * numIndex + offset, context.maxXLimit);
    matrix = subSet(y, x, context.blue, context.boxSize);
    dct = matrixDct(matrix, context.D);
    if bit == 1
        dct1 = encodeOne(dct, context.delta);
    else
        dct1 = encodeZero(dct, context.delta);
    end
    idct = matrixIdct(dct1, context.D);
    context.blue = writeSubSetBack(idct, y, x, context.blue, context.boxSize);
end
result = context.blue;
end

function [dct]=encodeOne(dct, delta)
[x1Encode, y1Encode] = getFirstIndexStub(size(dct, 1));
[x2Encode, y2Encode] = getSecondIndexStub(size(dct, 1));
diff = abs(dct(y1Encode, x1Encode)) - abs(dct(y2Encode, x2Encode));

if diff > -delta
    %             decrease delta
    dct(y2Encode, x2Encode) = getIncreased(dct(y1Encode, x1Encode), 1.5 * delta);
end
end

function [val] = getIncreased(base, delta)
module = abs(base);
val = base * (1 + delta / module);
end

function [dct]=encodeZero(dct, delta)
[x1Encode, y1Encode] = getFirstIndexStub(size(dct, 1));
[x2Encode, y2Encode] = getSecondIndexStub(size(dct, 1));
diff = abs(dct(y1Encode, x1Encode)) - abs(dct(y2Encode, x2Encode));

if diff <= delta
    %             increase delta
    dct(y1Encode, x1Encode) = getIncreased(dct(y2Encode, x2Encode), 1.5 * delta);
end
end

function [dct] = matrixDct(m, koeficient)
dct = koeficient*m*koeficient';
end

function [idct] = matrixIdct(m, koeficient)
idct = koeficient'*m*koeficient;
end

function reduced =adjust(img, filename, boxSize)
[sizeY, sizeX, ~] = size(img);
maxYLimit = fix(sizeY / boxSize);
maxXLimit = fix(sizeX / boxSize);

% reducedFilename = strcat('reduced__', filename);
reduced = img(1:maxYLimit * boxSize, 1:maxXLimit * boxSize,:);
% imwrite(reduced, reducedFilename);
end

function [img, encodedFilename]=saveEncoded(img, blue, filename)
img(:,:,1) = blue;
img(:,:,2) = blue;
img(:,:,3) = blue;
encodedFilename = strcat('encoded__', filename);
imwrite(img, encodedFilename);
end

function [subMatrix] = subSet(y, x, img, boxSize)
startX = (x - 1) * boxSize + 1;
startY = (y - 1) * boxSize + 1;
subMatrix = img(startY:boxSize * y,startX:boxSize * x);
end

function [img] = writeSubSetBack(subMatrix, y, x, img, boxSize)
startX = (x - 1) * boxSize + 1;
startY = (y - 1) * boxSize + 1;
img(startY:boxSize * y,startX:boxSize * x) = subMatrix;
end

function [y, x] = getFirstIndexStub(boxSize)
[y, x] = getIndex(3, boxSize);
end

function [y, x] = getSecondIndexStub(boxSize)
[y, x] = getIndex(13, boxSize);
end


function [y, x] = getIndex(val, boxSize)
y = fix(val / boxSize) + 1;
x = mod(val, boxSize) + 1;
end
