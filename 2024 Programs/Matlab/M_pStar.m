% -------------------------------------------------------------------------
% M_pStar.m: MAX value and optimal price at each state with quadratic 
% interpolation on V
% -------------------------------------------------------------------------

function [pStar,fp,flag,Vstar] = M_pStar(V, Pgrid)
 

[nump,nums] = size(V);
pStar       = NaN*ones(1,nums);
Vstar       = NaN*ones(1,nums);
fp          = zeros(nump,nums);
flag        = 0;

[~, maxind] = max(V);
maxind_o    = maxind;
if  min(maxind) ==1 || max(maxind)==nump                                % make sure solution is interior
    flag   = 1;
    maxind = min(max(maxind,2),nump-1);
end

localx    = [Pgrid(maxind-1)';Pgrid(maxind)';Pgrid(maxind+1)'];         % 3 points on price grid around optimum
XMATstack = [ones(size(localx));localx;localx.^2];                      % regressor matrix: const, grid and grid^2

for col=1:nums
    if maxind_o(col)==1 || maxind_o(col)==nump
        pStar(col)            = Pgrid(maxind_o(col));
        fp(maxind_o(col),col) = 1;
        Vstar(col)            = V(maxind_o(col),col);
    else
        XMAT       = reshape(XMATstack(:,col),3,3);                      % regressor matrix at state "col"
        localV     = V(maxind(col)-1:maxind(col)+1,col);                 % explained variable
        betacoeff  = (XMAT'*XMAT)\XMAT'*localV;                          % regression coefficient
        pStar(col) = -0.5*betacoeff(2)/betacoeff(3);                     % maximant of interpolant
        Vstar(col) = [1 pStar(col) pStar(col)^2]*betacoeff;              % maximum of interpolant
        
        index      = find(pStar(col)<Pgrid,1,'first');

        fp(index-1,col) = (Pgrid(index)-pStar(col))/(Pgrid(index)-Pgrid(index-1));
        fp(index,col)   = (pStar(col)-Pgrid(index-1))/(Pgrid(index)-Pgrid(index-1));

        if isempty(index)
            pStar(col)           = Pgrid(maxind_o(col));
            fp(maxind_o(col),col)= 1;            
        end
    end
end

