%% ------------------------------------------------------------------------
% MakeGrids.m: Make grids
% -------------------------------------------------------------------------
% Wage Rigidity, Endogenous Separations, and Labor productivity
% Joaquin Garcia-Cabo, Camilo Morales-Jimenez, Vivek Naranyan
% -------------------------------------------------------------------------
% This version: Spring 2025
% -------------------------------------------------------------------------

% Grid workers productivity
[evecx, Pe] = tauchen(Ne,0,rho_e,sig_e*(1-rho_e^2)^0.5,mz);
evecx       = exp(evecx);
p0e         = ergodicpi(Pe);
pos_rigidl  = floor(Ne*grid_rigid_);
pos_rigidu  = ceil(Ne*grid_rigid_);
ww_rigid_   = ceil(Ne*grid_rigid_)-Ne*grid_rigid_;

% Grid firms productivity
[fvecx, Pf] = tauchen(Nf,0,rho_f,sig_f*(1-rho_f^2)^0.5,mz);
fvecx       = exp(fvecx);
p0f         = ergodicpi(Pf);

% Overall grid
evec = kron(evecx,ones(Nf,1));
fvec = kron(ones(Ne,1),fvecx);
zvec = evec.*fvec;
Nz   = Ne*Nf;
Pz   = kron(Pe,Pf); 

% Wages
wvec = exp(log(1.1*min(zvec)):w_step:log(1.1*max(zvec)))';
%wvec(wvec<0.3247)=[];
%wvec(wvec>2.3994)=[];
Nw   = length(wvec);

% Eroding matrix
RECURSEMAT = Rmatrix(Nw, pi_ss, w_step);  