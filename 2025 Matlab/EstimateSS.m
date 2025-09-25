
% % % 
% % % espar = {'fbar'   0.1    0.8
% % %          'rho_e'  0.01   0.99
% % %          'sig_e'  0.005  0.4
% % %          'rho_f'  0.01   0.99
% % %          'sig_f'  0.005  0.4
% % %          'b_bar'  0      1};
% % % 
% % % 
% % % espar = {'fbar'        0.1    0.8
% % %          'rho_e'       0.01   0.99
% % %          'sig_e'       0.005  0.4
% % %          'rho_f'       0.01   0.99
% % %          'sig_f'       0.005  0.4
% % %          'b_bar'       0      1
% % %          'lbdw'        0      1   % Fraction of wage changes
% % %          'lbdw_n'      0      1   % Separation by tenure
% % %          'rhoJ0'       0      1
% % %          'rhoWhu'      0      1
% % %          'theta_w'     0      1
% % %          'thta'        0      1
% % %          'chi'         1.01   5
% % %          'dlta'        0      0.01
% % %          'grid_rigid_' 1/7+1e-5      1-1e-5}; % Ne=7 below this number it gets tricky
% % % 
% % % 
% % % quit_rate_t = 0.008;
% % % layoff_t    = 0.014;
% % % u_t         = 0.057;
% % % by_t        = 0.06;
% % % micro_regw  = -0.382;
% % % sep_t1      = 0.08;
% % % sep_t2      = 0.06;
% % % sep_t3      = 0.04;
% % % wage_d_t    = 0.0759528;
% % % wage_f0c    = 1-0.9038968-wage_d_t;
% % % wchange_p10 = -0.238409;
% % % wchange_p25 = -0.0645363;
% % % wchange_p50 = 0.0419643;
% % % wchange_p75 = 0.162519;
% % % wchange_p90 = 0.3074846;
% % % 
% % % data_mom = [quit_rate_t; layoff_t; u_t; by_t; micro_regw; sep_t1; sep_t2; sep_t3; wage_d_t; wage_f0c; wchange_p10; wchange_p25; wchange_p50; wchange_p75; wchange_p90];
% % % 
% % % x0 = [0.4 0.97 0.085 0.95 0.125 0.1 0.95 0.5 0.1 0.1 0.2 0.5 1.5 0.005 0.5]';
% % % 
% % % fmin_ = @(x)CalibrateSS(x,espar,data_mom);
% % % options_fm = optimset('display','iter');
% % % [xest, fest] = fminsearch(fmin_,x0,options_fm);
% % % [espar(:,1) num2cell(xest(:))]
% % % 
% % % 
% % % [xest, fest] = fminsearch(fmin_,xest,options_fm);
% % % [espar(:,1) num2cell(xest(:))]
% % % save preli2
% % % 
% % % 
% % % %%
% % % 
% % % 
% % % espar = {'fbar'   0.1    0.8
% % %          'rho_e'  0.01   0.99
% % %          'sig_e'  0.005  0.4
% % %          'rho_f'  0.01   0.99
% % %          'sig_f'  0.005  0.4
% % %          'b_bar'  0      1};
% % % 
% % % 
% % % espar = {'fbar'        0.1    0.8
% % %          'rho_e'       0.01   0.99
% % %          'sig_e'       0.005  0.4
% % %          'rho_f'       0.01   0.99
% % %          'sig_f'       0.005  0.4
% % %          'b_bar'       0      1
% % %          %'lbdw'        0      1   % Fraction of wage changes
% % %          'lbdw_n'      0      1   % Separation by tenure
% % %          'rhoJ0'       0      1
% % %          'rhoWhu'      0      1
% % %          'theta_w'     0      1
% % %          'thta'        0      1
% % %          'chi'         1.01   5
% % %          'dlta'        0      0.01
% % %           'grid_rigid_' 1/7+1e-5      1-1e-5}; % Ne=7 below this number it gets tricky
% % % 
% % % 
% % % quit_rate_t = 0.008;
% % % layoff_t    = 0.014;
% % % u_t         = 0.057;
% % % by_t        = 0.06;
% % % micro_regw  = -0.382;
% % % sep_t1      = 0.08;
% % % sep_t2      = 0.06;
% % % sep_t3      = 0.04;
% % % wage_d_t    = 0.0759528;
% % % wage_f0c    = 1-0.9038968-wage_d_t;
% % % wchange_p10 = -0.238409;
% % % wchange_p25 = -0.0645363;
% % % wchange_p50 = 0.0419643;
% % % wchange_p75 = 0.162519;
% % % wchange_p90 = 0.3074846;
% % % 
% % % data_mom = [quit_rate_t; layoff_t; u_t; by_t; micro_regw; sep_t1; sep_t2; sep_t3; wage_d_t; wage_f0c; wchange_p10; wchange_p25; wchange_p50; wchange_p75; wchange_p90];
% % % 
% % % x0 = [0.4 0.97 0.085 0.95 0.125 0.1  0.5 0.1 0.1 0.2 0.5 1.5 0.005 0.5]';
% % % 
% % % fmin_ = @(x)CalibrateSS(x,espar,data_mom);
% % % options_fm = optimset('display','iter');
% % % [xest, fest] = fminsearch(fmin_,x0,options_fm);
% % % [espar(:,1) num2cell(xest(:))]
% % % save preli3
% % % 
% % % [xest, fest] = fminsearch(fmin_,xest,options_fm);
% % % [espar(:,1) num2cell(xest(:))]
% % % save preli3
% % % 
% % % 
% % % %%
% % % 
% % % espar = {'fbar'        0.1    0.8
% % %          'rho_e'       0.01   0.99
% % %          'sig_e'       0.005  0.4
% % %          'rho_f'       0.01   0.99
% % %          'sig_f'       0.005  0.4
% % %          'b_bar'       0      1
% % %          %'lbdw'        0      1   % Fraction of wage changes
% % %          'lbdw_n'      0      1   % Separation by tenure
% % %          'rhoJ0'       0      1
% % %          'rhoWhu'      0      1
% % %          'theta_w'     0      1
% % %          'thta'        0      1
% % %          'chi'         1.01   5
% % %          'dlta'        0      0.01
% % %           'grid_rigid_' 1/7+1e-5      1-1e-5}; % Ne=7 below this number it gets tricky
% % % 
% % % 
% % % quit_rate_t = 0.008;
% % % layoff_t    = 0.014;
% % % u_t         = 0.057;
% % % by_t        = 0.06;
% % % micro_regw  = -0.382;
% % % sep_t1      = 0.08;
% % % sep_t2      = 0.06;
% % % sep_t3      = 0.04;
% % % wage_d_t    = 0.0759528;
% % % wage_f0c    = 1-0.9038968-wage_d_t;
% % % 
% % % data_mom = [quit_rate_t; layoff_t; u_t; by_t; micro_regw; sep_t1; sep_t2; sep_t3; wage_d_t; wage_f0c];
% % % 
% % % x0 = [0.4 0.97 0.085 0.95 0.125 0.1  0.5 0.1 0.1 0.2 0.5 1.5 0.005 0.5]';
% % % 
% % % fmin_ = @(x)CalibrateSS(x,espar,data_mom);
% % % options_fm = optimset('display','iter');
% % % [xest, fest] = fminsearch(fmin_,x0,options_fm);
% % % [espar(:,1) num2cell(xest(:))]
% % % 
% % % % This didn't have unemployment in the residual
% % % save preli4
% % % 
% % % 
% % % lb_ = cell2mat(espar(:,2));
% % % ub_ = cell2mat(espar(:,3));
% % % options = optimoptions('patternsearch','UseParallel', true, 'UseCompletePoll', true, 'UseVectorized', false,'Display','iter','MaxTime',3600);
% % % [xest, fxes,exitflag_]= patternsearch(fmin_,xest,[],[],[],[],lb_,ub_,options);
% % % 
% % % [xest, fest] = fminsearch(fmin_,xest,options_fm);
% % % 
% % % %%
clear;
addpath('/if/research-afe/joaquin/nlopt_test');

load 9_22_25_global.mat  %these are 13 params
x0(1:14) = xopt;
x0(15) = 0.75;
espar = {'fbar'        0.44    0.5
         'rho_e'       0.93   0.97
         'sig_e'       0.12   0.2         
         'sig_f'       0.05   0.12
         'b_bar'       0.05   0.12
         'rho_f'       0.84   0.93
         'dlta'        0.005  0.012
         'rhoJ0'       0.10   0.18
         'rhoWhU'      0.15   0.30
         'theta_w'     0.30   0.5
         'thta'        0.30   0.5
         'chi'         1.25   2.5
         'lbdw'        0.75   0.90   % Fraction of wage changes
         'lbdw_n'      0.20   0.65
         'grid_rigid_' 0.40   0.85};
         
         
%  'grid_rigid_' 1/7+1e-5      1-1e-5}; % Ne=7 below this number it gets tricky
espar_struct = cell2struct(espar(:,2:3), espar(:,1), 1);
names = fieldnames(espar_struct);
n_length = length(names);
lb = zeros(n_length, 1);
ub = zeros(n_length, 1);
bounds = zeros(2,1);
for k = 1:n_length
    bounds(:,1) = [espar_struct.(names{k})];
    lb(k) = bounds(1);
    ub(k) = bounds(2);
end


%x0 = [  0.3368    0.9220    0.1149    0.1106    0.0399    0.9154    0.0017    0.1807    0.1967    0.7802    0.6774    2.5183    0.9167]';%
%xalt =[0.100000 0.891131 0.110167 0.177598 0.098475 0.874286 0.005446 0.008517 0.500000 1.000000 0.618983 3.000000];
opt.algorithm = NLOPT_G_MLSL_LDS
%NLOPT_LN_SBPLX %NLOPT_GN_DIRECT_L %NLOPT_LN_COBYLA %NLOPT_G_MLSL_LDS%
opt.local_optimizer.algorithm = NLOPT_LN_SBPLX 
opt.lower_bounds = lb;
opt.upper_bounds = ub;
opt.min_objective = @CalibrateSS
opt.maxeval = 10000;
opt.xtol_rel = 1e-5;
opt.local_optimizer.ftol_rel = 1e-4;

%fmin_ = @(x)CalibrateSS(x,espar,data_mom);
%options_fm = optimset('display','iter');
%[xest, fest] = fminsearch(fmin_,x0,options_fm);
%[espar(:,1) num2cell(xest(:))]
%lb_ = cell2mat(espar(:,2));
%ub_ = cell2mat(espar(:,3));
%options = optimoptions('patternsearch','UseParallel', true, 'UseCompletePoll', true, 'UseVectorized', false,'Display','iter','MaxTime',3600);
%[xest, fxes,exitflag_]= patternsearch(fmin_,xest,[],[],[],[],lb_,ub_,options);
%[xest, fest] = fminsearch(fmin_,xest,options_fm);

% Perform the optimization
[xopt, fmin, retcode] = nlopt_optimize(opt, x0)
% This didn't have unemployment in the residual
% save preli4

% Display results
fprintf('Optimal x: [%f, %f]\n', xopt);
fprintf('Minimum value: %f\n', fmin);
fprintf('Return code: %d\n', retcode);


save 9_24_25_global.mat