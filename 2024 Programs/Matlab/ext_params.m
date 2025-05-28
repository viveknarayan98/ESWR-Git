%% This codes declares all parameters and fixes external ones

%--- Grids
Nz = 41;   % Human capital points
Nw = 35;   % wage points
Nx = 1;    % Aggregate states

NS = Nz*Nw*Nx;  % vectorized states

%--- Preferences
sigma = 2;              % curvature of utility                                               %EXTERNAL
beta  = 0.99^(1/3);     % discount factor                                                    %EXTERNAL

%--- Technology
alpha   = 1-2/3;                     % Capital share                                          %EXTERNAL         
mu_bar  = log(2.7);                  % long run productivity (KMP)  -> used to be log(2.27)   %INTERNAL
rho_z   = 0.86; %0.90;               % Persistence of match productivity (KMP)                %INTERNAL
sg_z    = 0.18;% 0.255;                     % std-dev match productivity (KMP)                       %INTERNAL
rho_f   = 0.92; %0.90;               % Persistence of firm productivity                       %INTERNAL
sg_f    = 0.255/2.5;                     % std-dev firm productivity                       %INTERNAL
gma     = 1.5;                       % matching function elasticity (BN)                      %EXTERNAL/INTERNAL
delta_k = 1.1^0.25-0.701;            % Capital depre    
Px      = 1;                         % Marginal cost in ss

thta   = 0.80;                      % firm's nash bairganing parameter                       %EXTERNAL/INTERNAL

tiny = 10^(-5);

%--- Grids and functions
zvec = 189*ones(Nz,1);           % Human capital grid      
Pz  = 0*ones(Nz,Nz);             % transition matrix for  human capital
xvec = 189*ones(Nx,1);           % Agg state grid   

%Svec = 189*ones(NS,3);              % S = (w,z,x)
%zind = 189*ones(NS,1);
%wind = 189*ones(NS,1);
%xind = 189*ones(NS,1);

mz   = 3;   % for Tauchen
chi    = 1.5;             % Corvature of hiring cost
co      = 0.15*ones(1,1);       % operating cost (per period)
phi_bar = 1.1;                   % matching efficiency
fbar    = 0.35;                  % job finding probability
qbar    = 0.70;                  % prob of filling a vacancy
lbdw  = 11/12;                     %Prob no wage change
%--- internally calibrated parameters
%b_bar = 0.35;
%dlta    = 0.004;                 % exogenous sep rate
%kppa    = 0;                     % cost of posting a vacancy
%%%%
%rhoJ0  = 0.1;%0.05;
%rhoWhU = 0.1;%0.05;