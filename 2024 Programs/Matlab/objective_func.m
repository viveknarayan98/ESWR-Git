function sol=objective_func(x)
global nmom np datmom iter_mom
disp('x')
x

%% SOLVE FOR SS AND STATIONARY DISTRIBUTION GIVEN x-- Cmod(x) %%
run main_ss

%% CONSTRUCT OBJETIVE FUNCTION AS %%
% Fn=(Cmod(x(np)-Cdata)/Cdata+gama (Fn should be nmomx1)
% sol=Fn'*Wmat_sq*Fn

WMat_sq=eye(nmom); %identity matrix-same weight for all the moments
Fn=zeros(1,nmom);
gama(nmom)=0.0; % scaling parameter for moments close to 0
datmom_abs=abs(datmom);
for i_m=1:nmom
    Fn(1,i_m)=(modmom(i_m)-datmom(i_m))/(datmom_abs(i_m)+gama(i_m));
end
Fnt = transpose(Fn);
% F*SQRT(W)
FnW = WMat_sq*Fnt; % (nmom x nmom) x (nmom x 1)
% F'*W*F (1 x nom) x (nom x 1)
sol=Fn*FnW
iter_mom=iter_mom+1
end