% vsearchprm(y,v,vprm) returns an integer with the two closest points in v to y
% Input: 
%   y    = Ny x 1 vector
%   v    = Nv x 1 vector
%   vprm = real - curvature parameter in v
% Output:
%   ind = Ny x 1 vector
% 
% Routine assumes v is constructed as: 
% 		v = vmin + (vmax-vmin)*(x**1/vprm)
% with vmin = v(1), vmax = v(Nv), where x is an Nv by 1 vector uniformly distributed between 0 and 1.
% vprm is the curvature: vprm = 0 for L-shaped, vprm = 1 for linear
% 
% Note:
% if y(i) <= v(1) : ind(i) = 1
% if y(i) >= v(p) : ind(i) = p-1
% else            : v(ind(i)) <= y(i) < v(ind(i)+1)

function ind = vsearchprm(y,v,vprm) 

Nv = size(v,1);
Dx = 1.0D0/(Nv-1);

vmin = v(1); vmax = v(Nv);	

yhat = ((y-vmin)/(vmax-vmin)).^vprm;

nhat = 1.0D0 + (yhat/Dx);

indx = floor(nhat);

ind  = (y>=vmax)*(Nv-1) + (y<=vmin)*1 + (y<vmax).*(y>vmin).*indx;
return

