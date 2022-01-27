function output = myCDF(input)
input = input+1;
dimX = size(input,1);
dimY = size(input,2);

total_pixels = dimX.*dimY;
probability_array = double(zeros(1,256));
temp = double(zeros(1,256));
for i=1:dimX
    for j=1:dimY
       probability_array(1,input(i,j)) = probability_array(1,input(i,j))+1;
    end
end
probability_array = probability_array./total_pixels;

for i=1:256
    temp(1,i) = sum(probability_array(1,1:i));
end
output = temp;
end
