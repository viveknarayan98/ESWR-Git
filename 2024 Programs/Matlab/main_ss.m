%Last edit: 5/14/2025
cdir = pwd;
set(0,'DefaultFigureWindowStyle','docked')

%Load fixed parameter values
run ext_params
est = 2; %For plotting

%Assign internal parameters
i_p=1;
dlta   = x(i_p,1); i_p = i_p+1; % Exogenous separation
rhoJ0  = x(i_p,1); i_p = i_p+1; % Firing decision
rhoWhU = x(i_p,1); i_p = i_p+1; % Quitting decision
b_bar  = x(i_p,1); % UI


loadSS_VF = 0;
loadSS_mu = 0;
run V_iter_v3
run Mod_moments


%% set-up
% %--- Grid for x: for now one point
% 
% xvec(1) = 1;
% %--- Grid for z and Pz
% [zvecx, Pz(1:Nz,1:Nz)] = tauchen(Nz,mu_bar,rho_z,sg_z,3);
% zvecx = exp(zvecx);
% zvec(:,1) = zvecx;
% 
% 
% 
% %--- Unconditional dist for z --> except for z=0
% piz = 189*ones(Nz,1);
% piz(:,1) = ergodicpi(Pz(1:Nz,1:Nz));
% 
% muaz = 189*ones(1,1); 
% muaz(1,1) = sum(piz(:,1).*zvec(1:Nz,1));
% 
% 
% %---wage grid
% wvprm = 0.40;  % =0 for L-shaped, =1 for uniform
% wmin = 0.10*muaz(1); wmax = 0.35*max(zvec(:));
% 
% gxw  = linspace(0,1,Nw)';
% wvec = gxw.^(1/wvprm);
% wvec = wmin + (wmax-wmin)*wvec;  % wvec = linspace(wmin,wmax,Nw)';
% 
% figure(14)
% plot(1:Nw,wvec,'marker','o')

% %--- vectorized states
% iS = 1;
% for iz = 1:Nz  
% for iw = 1:Nw
% for ix = 1:Nx    
%     Svec(iS,:) = [wvec(iw), zvec(iz), xvec(ix)]; 
%     zind(iS)   = iz;
%     wind(iS)   = iw;
%     xind(iS)   = ix;
%     iS = iS+1;
% end
% end
% end

% figure(101); 
% plot(zvec(1:Nz),piz(:),'color',[0.4 0.4 0.8],'LineWidth',3); 
% set(gca,'Xgrid','on','Ygrid','on','Fontsize',21)
% xlabel('$z$','Interpreter','LaTex','Fontsize',23)
% title('Ergodic $\mu(z)$','Interpreter','LaTex','Fontsize',27)
% leg = legend('active');
% set(leg,'Interpreter','LaTex','Fontsize',23)
% legend boxoff

%--- output per match: z*x

%Y = Svec(:,2,:).*Svec(:,3,:);


