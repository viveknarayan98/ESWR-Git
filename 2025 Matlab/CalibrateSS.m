function res_ = CalibrateSS(x)
disp(x)
% beta=[];
quit_rate_t = 0.008;
layoff_t    = 0.014;
u_t         = 0.057;
by_t        = 0.06;
micro_regw  = -0.382;
sep_t1      = 0.08;
sep_t2      = 0.06;
sep_t3      = 0.04;
wage_d_t    = 0.0759528;
wage_f0c    = 1-0.9038968-wage_d_t;
macro_sep_w = 0.607;
macro_sep_prod = -0.936;

data_mom = [quit_rate_t; layoff_t; u_t; by_t; micro_regw; sep_t1; sep_t2; sep_t3; wage_d_t; wage_f0c; macro_sep_w; macro_sep_prod ];

% Load fixed parameter values
LoadParams;
w_step    = 0.02;
m_viter_i = 100;
m_viter_a = 50;
Ne        = 9;
Nf        = 9;

%Load params to estimate
espar = {'fbar' 
         'rho_e' 
         'sig_e'        
         'sig_f'
         'b_bar'
         'rho_f'
         'dlta' 
         'rhoJ0'
         'rhoWhU'
         'theta_w'
         'thta'
         'chi'
         'lbdw'
         'lbdw_n'
         'grid_rigid_'};
npar_ = length(x);
for jj=1:npar_
    eval([espar{jj,1},'=x(jj);'])
end
% Make grids
MakeGrids;


% Run value function iteration
disp_e_ = 0;
Viter_

% Compute post equilibriums stats
PostEq_cal

%PlotFigures
% if check_==0 & DIFF_>10*tol_Viter
%     res_ = realmax;
%     return
% end
OtherStats;

Mom_ = [quit_rate
        end_sep_rate
        u
        bY
        beta_logit(2)
        sep_by_tenure_a(1)
        sep_by_tenure_a(2)
        sep_by_tenure_a(3)
        frac_wage_d
        w0_change(end)./E_level(end)
        beta_macro_sep(end-1)
        beta_macro_sep(end)]
        %pctl_wchange(:)];

W1 = eye(5,5);
W2 = 0*eye(3,3);
W3 = eye(2,2);

%Adjust weighting
W1(1,1) = 8; %5;
W1(2,2) = 8; %5;
W1(3,3) = 8; %5;
%W3(1,1) = 1; %2;
%W3(2,2) = 1; %2; 

res_ = (Mom_-data_mom)./data_mom;
%res_=res_(1:5)'*W1*res_(1:5) +res_(8:10)'*W2*res_(8:10)+ res_(11:12)'*W3*res_(11:12);
res_=res_(1:5)'*W1*res_(1:5) + res_(11:12)'*W3*res_(11:12);
%     res_(6:8)=[];
%    res_=res_(1:5)'*res_(1:5) + (beta_macro_sep(end-1)/0.5-1)^2 + (beta_macro_sep(end)/-0.9-1)^2;
% res_ = res_(:)'*res_(:) + sum(diff(lwj_distri,[],2).^2)*100;% + (u-data_mom(3))^2*10000;

if isnan(res_)
    disp('The value is NaN.');
    res_=1e+10;
end

fprintf('x: %f\n', x);
fprintf('value: %f\n', res_);
PrintStats
end


