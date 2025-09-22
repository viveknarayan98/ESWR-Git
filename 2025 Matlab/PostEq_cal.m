%% ------------------------------------------------------------------------
% PostEq_cal.m: Computes equilibrium objects after value function iteration
% -------------------------------------------------------------------------
% Wage Rigidity, Endogenous Separations, and Labor productivity
% Joaquin Garcia-Cabo, Camilo Morales-Jimenez, Vivek Naranyan
% -------------------------------------------------------------------------
% This version: Spring 2025
% -------------------------------------------------------------------------

%% ------------------------------------------------------------------------
% Macro variables
% -------------------------------------------------------------------------
% Free entry
V     = sum(muU(:))*fbar/qbar;
vj    = vj/(vj*p0f)*V;
kappa = (qbar*avJ(Nf))./(vj(Nf).^chi);
rk    = 1/beta-(1-delta_k);

% Efective employment by firms
n_f = sum((muE.*evec')*kron(ones(Ne,1),eye(Nf)));

% TFP by firm
A_f = (fvecx'./((1-alpha)*Px^(1/(1-alpha))*(alpha/rk)^(alpha/(1-alpha)))).^(1-alpha);

% Aggregate capital
K_f  = ((alpha*Px*A_f)./rk).^(1/(1-alpha)).*n_f;
K    = sum(K_f);

% Aggregate production
y_f = A_f.*K_f.^alpha.*n_f.^(1-alpha);
Y   = sum(y_f);

% Vacancy cost
Vcost = (kappa.*vj.^(1+chi)/(1+chi))*p0f;

% Consumption
C = Y - Vcost - delta_k*K;

% Investment, unemployment
u   = sum(muU(:));
r   = rk+1-delta_k;
I   = delta_k*K;




%% ------------------------------------------------------------------------
% Profit share
%--------------------------------------------------------------------------
PROF_SH = 100*((wvec'*muE)'./(zvec.*(sum(muE,1))'));


%% ------------------------------------------------------------------------
% Separations
%--------------------------------------------------------------------------

% Note: we assume that quits and separation happen before exogenous 

% separations
TotSep       = sum(sum((lbdw*RECURSEMAT*muE*Pz).*sep_ + (fw.*sum((1-lbdw)*RECURSEMAT*muE*Pz)).*sep_));
sep_rate     = TotSep/sum(sum(muE));

%Total quits as a share of employment
TotQuits     = sum(sum((lbdw*RECURSEMAT*muE*Pz).*quit_.*(1-fire_) + (fw.*sum((1-lbdw)*RECURSEMAT*muE*Pz)).*quit_.*(1-fire_)));
quit_rate    = TotQuits/sum(sum(muE));

%Total endogenous separations as a share of employment
TotEndSep    = sum(sum((lbdw*RECURSEMAT*muE*Pz).*fire_.*(1-quit_) + (fw.*sum((1-lbdw)*RECURSEMAT*muE*Pz)).*fire_.*(1-quit_)));
end_sep_rate = TotEndSep/sum(sum(muE));

%Total exogenous separations as a share of employment
TotExoSep    = sum(sum((lbdw*RECURSEMAT*muE*Pz).*(1-fire_).*(1-quit_).*dlta + (fw.*sum((1-lbdw)*RECURSEMAT*muE*Pz)).*(1-fire_).*(1-quit_).*dlta));
exo_sep_rate = TotExoSep/sum(sum(muE));

%Check if quit and sep at the same time
dsep_        = fire_.*quit_;
Totdsep      = sum(sum((lbdw*RECURSEMAT*muE*Pz).*dsep_ + (fw.*sum((1-lbdw)*RECURSEMAT*muE*Pz)).*dsep_));
dsep_rate    = Totdsep/sum(sum(muE));
check_sep    = exo_sep_rate + quit_rate + end_sep_rate + dsep_rate - sep_rate;

%% ------------------------------------------------------------------------
% Unemployment rate
%--------------------------------------------------------------------------
unemployment = sum(muU(:));


%% ------------------------------------------------------------------------
% Conditional separations
%--------------------------------------------------------------------------

% Probability of separation given current wage
sep_by_w =sum(muE.*sep_,2)./sum(muE,2);

% Separation by tenure
Tenure        = fbar*(lbdw_n*fw + (1-lbdw_n)*fw_rigid).*(1-sep_).*repmat(kron(muU*Pe,(vj.*p0f')/V),Nw,1);
sep_by_tenure = zeros(8*12,1);
for t=2:8*12
    Tenure(:,:,t)      = (lbdw*RECURSEMAT*Tenure(:,:,t-1)*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*RECURSEMAT*Tenure(:,:,t-1)*Pz)).*(1-sep_);  
    sep_by_tenure(t-1) = sum(sum((lbdw*RECURSEMAT*Tenure(:,:,t-1)*Pz).*sep_ + (fw.*sum((1-lbdw)*RECURSEMAT*Tenure(:,:,t-1)*Pz)).*sep_));  
end
sep_by_tenure(t) = sum(sum((lbdw*RECURSEMAT*Tenure(:,:,t)*Pz).*sep_ + (fw.*sum((1-lbdw)*RECURSEMAT*Tenure(:,:,t)*Pz)).*sep_));  
sep_by_tenure    = sep_by_tenure./squeeze(sum(sum(Tenure)));
sep_by_tenure_a  = kron(eye(8),ones(1,12)/12)*sep_by_tenure;

%% ------------------------------------------------------------------------
% Replacement rate : b_bar /avg(w, ten=1)
% -------------------------------------------------------------------------
replacement_wage         = b_bar/sum(sum(Tenure(:,:,1),2).*wvec);
average_replacement_wage = b_bar / sum(sum(muE,2).*wvec);
bY                       = ((b_bar*evecx')*muU(:)/u)/Y;

%% ------------------------------------------------------------------------
% Wage growth
% -------------------------------------------------------------------------
Survival = muE(:,:);
for t=2:13
    Survival(:,:,t) = (lbdw*RECURSEMAT*Survival(:,:,t-1)*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*RECURSEMAT*Survival(:,:,t-1)*Pz)).*(1-sep_);    
end

wage_growth = zeros(12,1);
for tt=2:13
    wage_growth(tt-1) = 100*((sum(sum(Survival(:,:,tt),2).*wvec)/sum(sum(Survival(:,:,tt))))/(sum(sum(Survival(:,:,1),2).*wvec)/sum(sum(Survival(:,:,1))))-1);
end

%% ------------------------------------------------------------------------
% Unemploy one year from now given current wage
% -------------------------------------------------------------------------
sep12_w    = nan(1,Nw);
w_changeM  = zeros(Nw);
w_change12 = zeros(1,2*Nw-1);
w0_change  = zeros(Nw,12);
E_level    = zeros(Nw,12);

parfor jj=1:Nw    
    if sum(muE(jj,:))>eps        
        [sep12_w(jj), w_changeM(:,jj), w0_change(jj,:), E_level(jj,:)] = compute_sep_wc12(jj,muE,muU,lbdw,RECURSEMAT,Pz,sep_,fw,fbar,lbdw_n,fw_rigid,Pe,vj,p0f,V,Nw,Ne,Nf);
    end
end

for jj=1:Nw
    w_change12(Nw+1-jj:2*Nw-jj) = w_change12(Nw+1-jj:2*Nw-jj)'+w_changeM(:,jj);
end
w_change12  = w_change12/sum(w_change12);
Fw_change12 = cumsum(w_change12);

w0_change   = sum(w0_change);
E_level     = sum(E_level);
awagec_grid = (-(Nw-1)*w_step:w_step:(Nw-1)*w_step)+pi_ss^12-1;

ind          = (Fw_change12>0.05 & Fw_change12<0.95);
if all(ind==0)
    frac_wage_d =-100000;
else
    pctl_wchange = interp1(Fw_change12(ind),awagec_grid(ind),[0.1 0.25 0.5 0.75 0.9],'pchip');
    frac_wage_d  = interp1(awagec_grid,cumsum(w_change12),-0.005,'pchip');
end 



%% ------------------------------------------------------------------------
% Micro regression
% -------------------------------------------------------------------------
WW_ = sum(muE,2);
xx_ = [ones(Nw,1) log(wvec)];
yy_ = sep12_w';
index_ = ~isnan(yy_);

WW_ = diag(WW_(index_));
xx_ = xx_(index_,:);
yy_ = yy_(index_);

beta_linear = (xx_'*WW_*xx_)\(xx_'*WW_*yy_);
sep12_wfit  = [ones(Nw,1) log(wvec)]*beta_linear;
w_change12  = w_change12/sum(w_change12(:));

wage_l     = kron(xx_(:,2),ones(2,1));
sep_l      = kron(ones(size(xx_(:,2))),[0;1]);
ww_l       = kron(diag(WW_),ones(2,1)).*(kron(yy_,[0;1])+kron(1-yy_,[1;0]));
beta_logit = glmfit(wage_l,sep_l,'binomial','link','logit','Weights',ww_l);

%% Wage distribution
distri_data    = [-0.4985 -0.3216 -0.1981 -0.0936 0.0043 0.1031 0.2093 0.3354 0.5136 0.4325]';


mlwage     = (sum(muE,2)/sum(muE(:)))'*log(wvec); 
stdlwage   = ((sum(muE,2)/sum(muE(:)))'*(log(wvec)-mlwage).^2).^0.5;
Edist_     = sum(muE,2)+1e-10;

if all(ind==0)
    lwj_distri =-100000*ones(size(distri_data'));
    lwj_distri  = [lwj_distri' distri_data];
else
    lwj_distri = [interp1(cumsum(Edist_)/sum(Edist_),log(wvec),0.1:0.1:0.9,'pchip')-mlwage, stdlwage];
    lwj_distri = [lwj_distri' distri_data];
end 




