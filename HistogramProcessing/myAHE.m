function output = myAHE(input, numtiles)
input = input+1;
dimX = size(input,1);
dimY = size(input,2);
tile_dimX = ceil(dimX./numtiles(1,1));
lasttile_dimX = dimX - (numtiles(1,1)-1).*tile_dimX;
tile_dimY = ceil(dimY./numtiles(1,2));
lasttile_dimY = dimY - (numtiles(1,2)-1).*tile_dimY;

output = uint8(zeros(dimX,dimY));

cdf_array = double(zeros(numtiles(1,1).*numtiles(1,2),256));
n_array = double(zeros(numtiles(1,1).*numtiles(1,2),256));
center_pos = zeros(numtiles(1,1),numtiles(1,2),2);

cnt =1;
for i=1:numtiles(1,1)
    for j=1:numtiles(1,2)
        if i~=numtiles(1,1) && j~=numtiles(1,2)
            for m=(i-1)*tile_dimX+1:i*tile_dimX
                for n=(j-1)*tile_dimY+1:j*tile_dimY
                    n_array(cnt,input(m,n)) = n_array(cnt,input(m,n))+1;
                end
            end
            center_pos(i,j,1) = (i-1).*tile_dimX+ceil(tile_dimX./2); 
            center_pos(i,j,2) = (j-1).*tile_dimY+ceil(tile_dimY./2);
            tmp = double(n_array(cnt,:))./(tile_dimX.*tile_dimY);
        elseif i~=numtiles(1,1) && j==numtiles(1,2)
            for m=(i-1)*tile_dimX+1:i*tile_dimX
                for n=(j-1)*tile_dimY+1:dimY
                    n_array(cnt,input(m,n)) = n_array(cnt,input(m,n))+1;
                end
            end
            center_pos(i,j,1) = (i-1).*tile_dimX+ceil(tile_dimX./2);
            center_pos(i,j,2) = (j-1).*tile_dimY+ceil(lasttile_dimY./2);
            tmp = double(n_array(cnt,:))./(tile_dimX.*lasttile_dimY);
        elseif i==numtiles(1,1) && j~=numtiles(1,2)
            for m=(i-1)*tile_dimX+1:dimX
                for n=(j-1)*tile_dimY+1:j*tile_dimY
                    n_array(cnt,input(m,n)) = n_array(cnt,input(m,n))+1;
                end
            end
            center_pos(i,j,1) = (i-1).*tile_dimX+ceil(lasttile_dimX./2);
            center_pos(i,j,2) = (j-1).*tile_dimY+ceil(tile_dimY./2);
            tmp = double(n_array(cnt,:))./(lasttile_dimX.*tile_dimY);
        else
            for m=(i-1)*tile_dimX+1:dimX
                for n=(j-1)*tile_dimY+1:dimY
                    n_array(cnt,input(m,n)) = n_array(cnt,input(m,n))+1;
                end
            end
            center_pos(i,j,1) = (i-1).*tile_dimX+ceil(lasttile_dimX./2);
            center_pos(i,j,2) = (j-1).*tile_dimY+ceil(lasttile_dimY./2);
            tmp = double(n_array(cnt,:))./(lasttile_dimX.*lasttile_dimY);
        end

        for k=1:256
            cdf_array(cnt,k) = sum(tmp(1,1:k));
        end
        cnt = cnt+1;
    end
end
for i=1:dimX
    for j=1:dimY
        row = floor((i-1)./tile_dimX) + 1;
        col = floor((j-1)./tile_dimY) + 1;
        if i<=ceil(tile_dimX./2) && j<=ceil(tile_dimY./2)%왼쪽 위 코너
            output(i,j) = round(255.*cdf_array(find_tile(row,col,numtiles),input(i,j)));
            
        elseif i<=ceil(tile_dimX./2) && j>ceil(tile_dimY./2)
            if j<dimY-ceil(lasttile_dimY./2) %위 초록색 부분
                if j>center_pos(row,col,2)
                    tile_one = find_tile(row,col,numtiles);
                    tile_two = find_tile(row,col+1,numtiles);
                    score = [round(255.*cdf_array(tile_one,input(i,j))) round(255.*cdf_array(tile_two,input(i,j)))];
                    centers = [center_pos(row,col,1) center_pos(row,col,2);center_pos(row,col+1,1) center_pos(row,col+1,2)];
                    output(i,j) = uint8(bilinear_interpolation(score, [i j], centers, 2));
                else
                    tile_one = find_tile(row,col-1,numtiles);
                    tile_two = find_tile(row,col,numtiles);
                    score = [round(255.*cdf_array(tile_one,input(i,j))) round(255.*cdf_array(tile_two,input(i,j)))];
                    centers = [center_pos(row,col-1,1) center_pos(row,col-1,2); center_pos(row,col,1) center_pos(row,col,2)];
                    output(i,j) = uint8(bilinear_interpolation(score, [i j], centers, 2));                    
                end
            else %오른쪽 위 코너
                output(i,j) = uint8(round(255.*cdf_array(find_tile(row,col,numtiles),input(i,j))));
            end
            
        elseif i>ceil(tile_dimX./2) && j<=ceil(tile_dimY./2)
            if i<dimX-ceil(lasttile_dimX./2) %왼쪽 초록색 부분
                if i>center_pos(row,col,1)
                    tile_one = find_tile(row,col,numtiles);
                    tile_two = find_tile(row+1,col,numtiles);
                    score = [round(255.*cdf_array(tile_one,input(i,j))) round(255.*cdf_array(tile_two,input(i,j)))];
                    centers = [center_pos(row,col,1) center_pos(row,col,2);center_pos(row+1,col,1) center_pos(row+1,col,2)];
                    output(i,j) = uint8(bilinear_interpolation(score, [i j], centers, 1));
                else
                    tile_one = find_tile(row-1,col,numtiles);
                    tile_two = find_tile(row,col,numtiles);
                    score = [round(255.*cdf_array(tile_one,input(i,j))) round(255.*cdf_array(tile_two,input(i,j)))];
                    centers = [center_pos(row-1,col,1) center_pos(row-1,col,2); center_pos(row,col,1) center_pos(row,col,2)];
                    output(i,j) = uint8(bilinear_interpolation(score, [i j], centers, 1));
                end
            else %왼쪽 아래 코너
                output(i,j) = uint8(round(255.*cdf_array(find_tile(row,col,numtiles),input(i,j))));
            end
        else
            if j<dimY-ceil(lasttile_dimY./2) && i<dimX-ceil(lasttile_dimX./2) %가운데 파란색 부분
                if j<=center_pos(row,col,2) && i<=center_pos(row,col,1)
                    tile_one = find_tile(row-1,col-1,numtiles);
                    tile_two = find_tile(row-1,col,numtiles);
                    tile_three = find_tile(row,col-1, numtiles);
                    tile_four = find_tile(row,col, numtiles);
                    score = [round(255.*cdf_array(tile_one,input(i,j))) round(255.*cdf_array(tile_two,input(i,j))) round(255.*cdf_array(tile_three,input(i,j))) round(255.*cdf_array(tile_four,input(i,j)))];
                    centers = [center_pos(row-1,col-1,1) center_pos(row-1,col-1,2); center_pos(row-1,col,1) center_pos(row-1,col,2); center_pos(row,col-1,1) center_pos(row,col-1,2); center_pos(row,col,1) center_pos(row,col,2)];
                    output(i,j) = uint8(bilinear_interpolation(score, [i j], centers, 3));
                elseif j>center_pos(row,col,2) && i<=center_pos(row,col,1)
                    tile_one = find_tile(row-1,col,numtiles);
                    tile_two = find_tile(row-1,col+1,numtiles);
                    tile_three = find_tile(row,col, numtiles);
                    tile_four = find_tile(row,col+1, numtiles);
                    score = [round(255.*cdf_array(tile_one,input(i,j))) round(255.*cdf_array(tile_two,input(i,j))) round(255.*cdf_array(tile_three,input(i,j))) round(255.*cdf_array(tile_four,input(i,j)))];
                    centers = [center_pos(row-1,col,1) center_pos(row-1,col,2); center_pos(row-1,col+1,1) center_pos(row-1,col+1,2); center_pos(row,col,1) center_pos(row,col,2); center_pos(row,col+1,1) center_pos(row,col+1,2)];
                    output(i,j) = uint8(bilinear_interpolation(score, [i j], centers, 3));
                elseif j<=center_pos(row,col,2) && i>center_pos(row,col,1)
                    tile_one = find_tile(row,col-1,numtiles);
                    tile_two = find_tile(row,col,numtiles);
                    tile_three = find_tile(row+1,col-1, numtiles);
                    tile_four = find_tile(row+1,col, numtiles);
                    score = [round(255.*cdf_array(tile_one,input(i,j))) round(255.*cdf_array(tile_two,input(i,j))) round(255.*cdf_array(tile_three,input(i,j))) round(255.*cdf_array(tile_four,input(i,j)))];
                    centers = [center_pos(row,col-1,1) center_pos(row,col-1,2); center_pos(row,col,1) center_pos(row,col,2); center_pos(row+1,col-1,1) center_pos(row+1,col-1,2); center_pos(row+1,col,1) center_pos(row+1,col,2)];
                    output(i,j) = uint8(bilinear_interpolation(score, [i j], centers, 3));
                else
                    tile_one = find_tile(row,col,numtiles);
                    tile_two = find_tile(row,col+1,numtiles);
                    tile_three = find_tile(row+1,col, numtiles);
                    tile_four = find_tile(row+1,col+1, numtiles);
                    score = [round(255.*cdf_array(tile_one,input(i,j))) round(255.*cdf_array(tile_two,input(i,j))) round(255.*cdf_array(tile_three,input(i,j))) round(255.*cdf_array(tile_four,input(i,j)))];
                    centers = [center_pos(row,col,1) center_pos(row,col,2); center_pos(row,col+1,1) center_pos(row,col+1,2); center_pos(row+1,col,1) center_pos(row+1,col,2); center_pos(row+1,col+1,1) center_pos(row+1,col+1,2)];
                    output(i,j) = uint8(bilinear_interpolation(score, [i j], centers, 3));
                end
            elseif j>=dimY-ceil(lasttile_dimY./2) && i<dimX-ceil(lasttile_dimX./2) %오른쪽 초록색 부분
                if i>center_pos(row,col,1)
                    tile_one = find_tile(row,col,numtiles);
                    tile_two = find_tile(row+1,col,numtiles);
                    score = [round(255.*cdf_array(tile_one,input(i,j))) round(255.*cdf_array(tile_two,input(i,j)))];
                    centers = [center_pos(row,col,1) center_pos(row,col,2); center_pos(row+1,col,1) center_pos(row+1,col,2)];
                    output(i,j) = uint8(bilinear_interpolation(score, [i j], centers, 1));
                else
                    tile_one = find_tile(row-1,col,numtiles);
                    tile_two = find_tile(row,col,numtiles);
                    score = [round(255.*cdf_array(tile_one,input(i,j))) round(255.*cdf_array(tile_two,input(i,j)))];
                    centers = [center_pos(row-1,col,1) center_pos(row-1,col,2); center_pos(row,col,1) center_pos(row,col,2)];
                    output(i,j) = uint8(bilinear_interpolation(score, [i j], centers, 1));
                end
            elseif j<dimY-ceil(lasttile_dimY./2) && i>=dimX-ceil(lasttile_dimX./2) %아래 초록색 부분
                if j>center_pos(row,col,2)
                    tile_one = find_tile(row,col,numtiles);
                    tile_two = find_tile(row,col+1,numtiles);
                    score = [round(255.*cdf_array(tile_one,input(i,j))) round(255.*cdf_array(tile_two,input(i,j)))];
                    centers = [center_pos(row,col,1) center_pos(row,col,2); center_pos(row,col+1,1) center_pos(row,col+1,2)];
                    output(i,j) = uint8(bilinear_interpolation(score, [i j], centers, 2));
                else
                    tile_one = find_tile(row,col-1,numtiles);
                    tile_two = find_tile(row,col,numtiles);
                    score = [round(255.*cdf_array(tile_one,input(i,j))) round(255.*cdf_array(tile_two,input(i,j)))];
                    centers = [center_pos(row,col-1,1) center_pos(row,col-1,2); center_pos(row,col,1) center_pos(row,col,2)];
                    output(i,j) = uint8(bilinear_interpolation(score, [i j], centers, 2));                    
                end
            else %오른쪽 아래 코너
                output(i,j) = uint8(round(255.*cdf_array(find_tile(row,col,numtiles),input(i,j))));
            end
        end
    end
end

end

function tile_num = find_tile(row,col,numtiles)
    tile_num = (row-1).*(numtiles(1,2))+col;
end

function bi_output = bilinear_interpolation(score, point, centers, lin_num)
    
    if lin_num==1 % 두점 linear-interpolation row 방향
        row_len = centers(2,1) - centers(1,1);
        dx = double(centers(2,1)-point(1,1))./row_len;
        bi_output = score(1,1).*(dx) + score(1,2).*(1-dx);
    elseif lin_num==2 % 두점 linear-interpolation col 방향
        col_len = centers(2,2) - centers(1,2);
        dy = double(centers(2,2)-point(1,2))./col_len;
        bi_output = score(1,1).*(dy) + score(1,2).*(1-dy);
    else % 네점 bilinear-interpolation
        row_len = centers(3,1)-centers(1,1);
        col_len = centers(2,2)-centers(1,2);
        dx = double(centers(4,1)-point(1,1))./row_len;
        dy = double(centers(4,2)-point(1,2))./col_len;
        
        bi_output = score(1,1).*(dx).*(dy) + score(1,2).*(dx).*(1-dy)+score(1,3).*(1-dx).*(dy)+score(1,4).*(1-dx).*(1-dy);
    end
end