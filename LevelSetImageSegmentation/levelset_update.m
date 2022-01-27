function phi_out = levelset_update(phi_in, g, c, timestep)
phi_out = phi_in;

%
% ToDo
%
[phi_gradx,phi_grady] = find_grad(phi_in);

dPhi = sqrt(phi_grady.^2+phi_gradx.^2); % mag(grad(phi))

eps = 1e-10;
dx = phi_gradx./(sqrt(phi_gradx.^2)+eps);
dy = phi_grady./(sqrt(phi_grady.^2)+eps);
[div_x, div_y] = find_grad(dx+dy);
kappa =  div_x+div_y;% curvature

smoothness = g.*kappa.*dPhi;
expand = c*g.*dPhi;

phi_out = phi_out + timestep*(expand + smoothness);

function [out_x,out_y] = find_grad(in)
[dimX,dimY] = size(in);
out_x = zeros(dimX,dimY);
out_y = zeros(dimX,dimY);
for x=2:dimX-1
    for y=2:dimY-1
        out_x(x,y) = (in(x+1,y+1)+2.*in(x+1,y)+in(x+1,y-1)-2.*in(x-1,y)-in(x-1,y+1)-in(x-1,y-1))./9;
        out_y(x,y) = (in(x-1,y+1)+2.*in(x,y+1)+in(x+1,y+1)-in(x-1,y-1)-2.*in(x,y-1)-in(x+1,y-1))./9;
    end
end
