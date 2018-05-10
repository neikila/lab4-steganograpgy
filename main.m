clear
constantToAdd = 15;
delta = 25;
encodeImage(constantToAdd, delta);

function []=encodeImage(constantToAdd, delta, message)
boxSize = 8;

filename = 'img.jpg';

img = adjust(imread(filename), boxSize, filename);

blue = img(:,:,3);
arr = size(blue) / boxSize;
maxYLimit = arr(1);
maxXLimit = arr(2);

D = dctmtx(8);
for x=1:maxXLimit
    for y=1:maxYLimit

        matrix = subSet(blue, x, y, boxSize);
        dct = matrixDct(matrix, D);
        
        
    end
end

end

function [dct]=encodeOne(dct, delta)
        [x1Encode, y1Encode] = getFirstIndexStub();
        [x2Encode, y2Encode] = getSecondIndexStub();
        diff = abs(dct(y1Encode, x1Encode)) - abs(dct(y2Encode, x2Encode));        

        if diff > -delta
%             decrease delta
            dct(y2Encode, x2Encode) = getIncreased(dct(y1Encode, x1Encode), delta + 1);
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
            dct(y1Encode, x1Encode) = getIncreased(dct(y2Encode, x2Encode), delta + 1);
        end
end


% idct = matrixIdct(dct, D);

function [dct] = matrixDct(m, koeficient)
    dct = koeficient*m*koeficient';
end

function [idct] = matrixIdct(m, koeficient)
    idct = koeficient'*m*koeficient;
end

function [reduced]=adjust(img, boxSize, filenameBase)
[sizeY, sizeX, ~] = size(img);
maxYLimit = fix(sizeY / boxSize);
maxXLimit = fix(sizeX / boxSize);

reducedFilename = strcat('reduced__',filenameBase);
reduced = img(1:maxYLimit*boxSize, 1:maxXLimit*boxSize,:);
imwrite(reduced,reducedFilename);
end

function [subMatrix] = subSet(img, y, x, boxSize)
    startX = (x - 1) * boxSize + 1;
    startY = (y - 1) * boxSize + 1;
    subMatrix = img(startY:boxSize * y,startX:boxSize * x);    
end

function [y, x] = getFirstIndexStub()
    [y, x] = getIndex(28, 8); 
end

function [y, x] = getSecondIndexStub()
    [y, x] = getIndex(39, 8); 
end


function [y, x] = getIndex(val, boxSize)
    y = fix(val / boxSize);
    x = mof(val / boxSize);
end
