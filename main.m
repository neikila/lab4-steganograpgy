clear
delete encoded*

delta = 25;
message = 'bccc';
filename = 'img.bmp';
encodeImage(delta, message, filename);
decodeMsg(delta, length(message), filename)

function [result]=decodeMsg(delta, charsAmount, filename)
context.boxSize = 8;
context.filename = filename;
encodedFilename = strcat('encoded__', context.filename);
context.delta = delta;

img = imread(encodedFilename);
context.blue = img(:,:,3);

arr = size(context.blue) / context.boxSize;
context.maxXLimit = arr(2);

context.D = dctmtx(8);

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
        [x1Encode, y1Encode] = getFirstIndexStub();
        [x2Encode, y2Encode] = getSecondIndexStub();
        diff = abs(dct(y1Encode, x1Encode)) - abs(dct(y2Encode, x2Encode));

        if diff <= -delta
            bit = 1;
        else
            bit = 0;
        end
end

function [encodedFilename]=encodeImage(delta, message, filename)
context.delta = delta;
context.boxSize = 8;
context.filename = filename;

img = adjust(imread(context.filename), context);
context.blue = img(:,:,3);

arr = size(context.blue) / context.boxSize;
context.maxXLimit = arr(2);
context.D = dctmtx(8);

ints = uint8(message);

for i = 1:length(ints)
    blueUpdated=encodeNum(ints(i), i, context);
    context.blue = blueUpdated;
end

[~, encodedFilename] = saveEncoded(img, context.blue, context.filename)
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
    idct = uint8(matrixIdct(dct1, context.D));
    context.blue = writeSubSetBack(idct, y, x, context.blue, context.boxSize);
end
result = context.blue;
end

function [dct]=encodeOne(dct, delta)
        [x1Encode, y1Encode] = getFirstIndexStub();
        [x2Encode, y2Encode] = getSecondIndexStub();
        diff = abs(dct(y1Encode, x1Encode)) - abs(dct(y2Encode, x2Encode));        

        if diff > -delta
%             decrease delta
            dct(y2Encode, x2Encode) = getIncreased(dct(y1Encode, x1Encode), 2 * delta);
        end
end

function [val] = getIncreased(base, delta)
val = base + sign(base) * delta;
end

function [dct]=encodeZero(dct, delta)
        [x1Encode, y1Encode] = getFirstIndexStub();
        [x2Encode, y2Encode] = getSecondIndexStub();
        diff = abs(dct(y1Encode, x1Encode)) - abs(dct(y2Encode, x2Encode));        

        if diff <= delta
%             increase delta
            dct(y1Encode, x1Encode) = getIncreased(dct(y2Encode, x2Encode), 2 * delta);
        end
end

function [dct] = matrixDct(m, koeficient)
    dct = koeficient*double(m)*koeficient';
end

function [idct] = matrixIdct(m, koeficient)
    idct = koeficient'*m*koeficient;
end

function [reduced]=adjust(img, context)
[sizeY, sizeX, ~] = size(img);
maxYLimit = fix(sizeY / context.boxSize);
maxXLimit = fix(sizeX / context.boxSize);

reducedFilename = strcat('reduced__', context.filename);
reduced = img(1:maxYLimit*context.boxSize, 1:maxXLimit*context.boxSize,:);
imwrite(reduced,reducedFilename);
end

function [img, encodedFilename]=saveEncoded(img, blue, filename)
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

function [y, x] = getFirstIndexStub()
    [y, x] = getIndex(28, 8); 
end

function [y, x] = getSecondIndexStub()
    [y, x] = getIndex(39, 8); 
end


function [y, x] = getIndex(val, boxSize)
    y = fix(val / boxSize) + 1;
    x = mod(val, boxSize) + 1;
end
