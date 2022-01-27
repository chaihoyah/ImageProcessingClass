function output = myHE(input)

input = input+1;
dimX = size(input,1);
dimY = size(input,2);
total_pixels = dimX.*dimY;
output = uint8(zeros(dimX,dimY));

cdf_array = double(zeros(1,256));
n_array = double(zeros(1,256));

for i=1:dimX
    for j=1:dimY
        n_array(1,input(i,j)) = n_array(1,input(i,j))+1;
    end
end

probability_array = double(n_array)./total_pixels;
for i=1:256
    cdf_array(1,i) = sum(probability_array(1,1:i));
end

for i=1:dimX
    for j=1:dimY
        if input(i,j)~=0
            output(i,j) = round(255.*cdf_array(1,input(i,j)));
        else
            output(i,j) = 1;
        end
    end
end
end

