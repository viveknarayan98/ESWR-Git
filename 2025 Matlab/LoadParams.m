%% ------------------------------------------------------------------------
% ext_params.m: load paramters for equilibrium
% -------------------------------------------------------------------------
% Wage Rigidity, Endogenous Separations, and Labor productivity
% Joaquin Garcia-Cabo, Camilo Morales-Jimenez, Vivek Naranyan
% -------------------------------------------------------------------------
% This version: Spring 2025
% -------------------------------------------------------------------------

% Computation
mz            = 3;              % Wide for Tauchen
tol_Viter     = 1e-4;           % Tolerance value function iteration
tol_muiter    = 1e-8;           % Tolerance distribution
max_out_loop  = 20;             % Maximum iteration for outer loops
max_dist_iter = 1000;           % Maximum iterations for distribution
smd_v_        = 0.9;            % How strong to start updating value function
p_smooth_     = 0.6;            % How fast to update new value function
m_viter_i     = 200;            % Maximum value function iteration for initial iteration
m_viter_a     = 100;            % Additional value function iterations after initial iteration

% Household preferences
sigma         = 2;              % Curvature of utility
beta          = 0.99^(1/3);     % Discount factor

% Productivity process (employees)
Ne            = 17;             % Grid points for workers
rho_e         = 0.97;           % Persistance of productivity shocks (workers)
sig_e         = 0.085;          % Starndard deviation of worker's productivity

% Productivity process (firms)
Nf            = 7;              % Grid points for firms
rho_f         = 0.95;           % Persistance of productivity shocks (firms)
sig_f         = 0.125;          % Starndard deviation of firm's productivity

% Labor market
eta           = 0.5;            % Matching elaticity
fbar          = 0.40;           % Job finding rate
qbar          = 0.70;           % Prob of filling a vacancy
chi           = 1.5;            % Corvature of hiring cost
uss           = 0.055;          % Target unemployment rate
Vss           = uss*fbar/qbar;  % Target vacancy
dlta          = 0.005;          % Exogenous separation rate

% Wages
lbdw_n        = 0.5;            % Probability of negotiating wages with new workers
lbdw          = 11/12;          % Probability of wage change 
w_step        = 0.005;          % Step for wage in grid
grid_rigid_   = 0.75;           % Wage that a new worker would get
rhoJ0         = 0.1;            % Cost to optimaly lay off
rhoWhU        = 0.2;            % Cost to optimaly quit
theta_w       = 0.25;           % Cost to set right wage
thta          = 0.75;           % Worker's bargaining power

% Agggregate economy
pi_ss         = 1.02^(1/12);    % Inflation in steady state
Psi           = 5;              % Capital adjustment cost
slope_pc      = 0.01;           % Slope of Phillips curve
rho_i         = 0.75;           % Taylor rule persistence
phi_pi        = 1.5;            % Coefficient on inflation
phi_Y         = 1/4;            % Coefficient on output gap
alpha         = 1-2/3;          % Capital share                                         
delta_k       = 1.1^0.25-1;     % Capital depre    
Px            = 1;              % Marginal cost in ss
b_bar         = 0.35;           % Outsize option