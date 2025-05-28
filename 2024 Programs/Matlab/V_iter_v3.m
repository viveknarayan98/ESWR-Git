% Relative to v2. This program assumes a distribution 
% for firms too.
%clc
%close all

v0     = zeros(NS,1);
w_step = 0.005;
pi_ss  = 1.02^(1/12);
uss    = 0.055;         % Target unemployment rate
Vss    = uss*fbar/qbar;

% Grid workers productivity
Ne          = 17; 
[evecx, Pe] = tauchen(Ne,mu_bar,rho_z,sg_z,3);
evecx       = exp(evecx);
p0e         = ergodicpi(Pe);


% Grid firms productivity
Nf          = 5; 
[fvecx, Pf] = tauchen(Nf,0.5,rho_f,sg_f,3);
fvecx       = exp(fvecx);
p0f         = ergodicpi(Pf);

% Overall grid
evec = kron(evecx,ones(Nf,1));
fvec = kron(ones(Ne,1),fvecx);
zvec = evec.*fvec;
Nz   = Ne*Nf;
Pz   = kron(Pe,Pf); 

% Expected value of employment
W_bar  = b_bar*evecx';


wvec = exp(log(0.5*min(zvec)):w_step:log(1.5*max(zvec)))';
Nw   = length(wvec);

Jaux = thta*(zvec'-wvec)/(1-beta);
Uval = (b_bar*evecx' + beta*fbar*W_bar)/(1-beta*(1-fbar));
Uaux = kron(Uval,ones(1,Nf));
Waux = (wvec)/(1-beta)+Uaux;

RECURSEMAT = Rmatrix(Nw, pi_ss, w_step);  

diff_wbar = 10;
wwmu      = 0.05;
showmu    = 1;
itmu      = 1;
tolmu     = 1e-5;

% %---measure for employed and unemployed
muE = ones(Nw,Nz); muE = (1-uss)*muE/sum(muE(:)); muU = uss*ones(1,Ne)/Ne;

iter_wbar = 0;
Jconto    = Jaux;
Wconto    = Waux;
while diff_wbar> tolmu & iter_wbar<20
    DIFF_   = 10;
    iter_V  = 0;    
    while DIFF_>1e-4 &  iter_V<1000        

        % Compute the best wage possible
        Nash_              = (Jaux.^thta).*(Waux-Uaux).^(1-thta);
        Nash_(Jaux<0)      = -realmax;
        Nash_(Waux-Uaux<0) = -realmax;

        [~,fw,flag,~] = M_pStar(Nash_, log(wvec));        

        if sum(sum(fw))~=Nz
            error('fw does not add to 1')
        end

        % Fire and quit decisions outside
        fire_   = PR_xtoy(0,Jaux,rhoJ0);     % firing decision
        quit_   = PR_xtoy(Uaux,Waux,rhoWhU); % quiting decision (note that it is wih Waux not Whx!)

        % Separation
        sep_ = 1-(1-dlta)*(1-fire_).*(1-quit_);

        % Optimal re-set values
        Jstar = sum(Jaux.*(1-sep_).*fw);
        Wstar = sum((Waux.*(1-sep_)+Uaux.*sep_).*fw);

        % Continuation value
        Jcont = lbdw*Jaux.*(1-sep_) + (1-lbdw)*Jstar;
        Wcont = lbdw*(Waux.*(1-sep_)+sep_.*Uaux) + (1-lbdw)*Wstar;        

        % New values
        Jnew  = zvec'- wvec + beta*RECURSEMAT'*Jcont*Pz';
        Wnew  = wvec + beta*RECURSEMAT'*Wcont*Pz';

        % On average, how much a firm with productivity j is paying a
        % worker with productivity i
        avJ = (sum(muE.*Jcont)./sum(muE))*kron(muU'/sum(muU(:)),eye(Nf));

        % Vacancies distribution
        vj  = (qbar*max(avJ,0)).^(1/chi);
        vj  = vj/(vj*p0f)*Vss;

        % Expected value of employment given vacancy distribution
        W_bar =(sum(muE.*Wcont)./sum(muE))*kron(eye(Ne),(vj.*p0f')'/Vss);

        % New value of unemployment
        Unew  = b_bar*evecx' + beta*((1-fbar)*Uval + fbar*W_bar)*Pe';

        % Tolarance
        %DIFF_ = [max(abs(Jnew(:)-Jaux(:)))    max(abs(Wnew(:)-Waux(:)))    max(abs(Unew(:)-Uval(:)))];
        DIFF_ = [max(abs(Jcont(:)-Jconto(:)))    max(abs(Wcont(:)-Wconto(:)))    max(abs(Unew(:)-Uval(:)))];
        DIFF_ = max(abs(DIFF_(:)));

        Jconto = Jcont;
        Wconto = Wcont;
        Jaux   = Jnew;
        Waux   = Wnew;
        Uval   = Unew;
        Uaux   = kron(Uval,ones(1,Nf));
        iter_V = 1+iter_V;
        
    end
    
    % Compute ergodic distribution
    diffmu = 1;
    itermu = 1;
    while diffmu>1e-7 & itermu<1000
        
        muEnew  = (lbdw*RECURSEMAT*muE*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*RECURSEMAT*muE*Pz)).*(1-sep_) + fbar*muE.*repmat(kron(muU*Pe,(vj.*p0f')/Vss),Nw,1)./sum(muE);
        muUnew  = (sum((lbdw*RECURSEMAT*muE*Pz).*sep_ + (fw.*sum((1-lbdw)*RECURSEMAT*muE*Pz)).*sep_))*kron(eye(Ne),ones(Nf,1)) + (1-fbar)*(muU*Pe);

        diffmu = max(abs([muEnew(:);muUnew(:)]-[muE(:);muU(:)]));
        muE = muEnew;
        muU = muUnew;
        itermu = itermu+1;

    end
        
    W_bar_new = (sum(muE.*Wcont)./sum(muE))*kron(eye(Ne),(vj.*p0f')'/Vss);
    diff_wbar = max(abs(W_bar_new(:)-W_bar(:)));
    fprintf('\nValue iteration %4.4f. distribution %4.4f. Wbar %4.4f',[DIFF_ diffmu diff_wbar])
    iter_wbar=iter_wbar+1;
end

fprintf('\n \n \n Equilibrium found... computing statistics... \n\n\n')

save aux_camilov3
%% Free entry

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


%% Statistics: To do Joaquin
%Profit share for a z worker ---> This looks very big for z <29
PROF_SH = 100*((wvec'*muE)'./(zvec.*(sum(muE,1))'));


% Note: we assume that quits and separation happen before exogenous 
% separations
TotSep = sum(sum((lbdw*muE*Pz).*sep_ + (fw.*sum((1-lbdw)*muE*Pz)).*sep_));
sep_rate = TotSep/sum(sum(muE));
%Total quits as a share of employment
TotQuits = sum(sum((lbdw*muE*Pz).*quit_.*(1-fire_) + (fw.*sum((1-lbdw)*muE*Pz)).*quit_.*(1-fire_)));
quit_rate = TotQuits/sum(sum(muE));
%Total endogenous separations as a share of employment
TotEndSep = sum(sum((lbdw*muE*Pz).*fire_.*(1-quit_) + (fw.*sum((1-lbdw)*muE*Pz)).*fire_.*(1-quit_)));
end_sep_rate = TotEndSep/sum(sum(muE));
%Total exogenous separations as a share of employment
TotExoSep = sum(sum((lbdw*muE*Pz).*(1-fire_).*(1-quit_).*dlta + (fw.*sum((1-lbdw)*muE*Pz)).*(1-fire_).*(1-quit_).*dlta));
exo_sep_rate = TotExoSep/sum(sum(muE));
%Check if quit and sep at the same time
dsep_ = fire_.*quit_;
Totdsep = sum(sum((lbdw*muE*Pz).*dsep_ + (fw.*sum((1-lbdw)*muE*Pz)).*dsep_));
dsep_rate = Totdsep/sum(sum(muE));
check_sep = exo_sep_rate + quit_rate + end_sep_rate + dsep_rate - sep_rate;

% Unemployment rate
unemployment=sum(muU(:));



%% Figures

% Probability of separation given current wage
sep_by_w =sum(muE.*sep_,2)./sum(muE,2);

% Separation by tenure
Tenure = fbar*muE.*repmat(kron(muU/sum(muU(:)),(vj.*p0f')/V),Nw,1)./sum(muE);
for t=2:40
    Tenure(:,:,t) = (lbdw*Tenure(:,:,t-1)*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*Tenure(:,:,t-1)*Pz)).*(1-sep_);    
end
sep_by_tenure = squeeze(sum(sum(Tenure.*sep_)))./squeeze(sum(sum(Tenure)));
% Replacement rate : b_bar /avg(w, ten=1)
replacement_wage = b_bar/sum(sum(Tenure(:,:,1),2).*wvec);
average_replacement_wage = b_bar / sum(sum(muE,2).*wvec);

% Unemploy one year from now given current wage
sep12_w    = nan(1,Nw);
w_change12 = zeros(1,2*Nw-1);%-w_step*(Nw-1):w_step:w_step*(Nw-1);
w0_change  = zeros(1,12);
E_level    = zeros(1,12);
for jj=1:Nw
    
    if sum(muE(jj,:))>eps        
    e12 = muE*0;
    u12 = muU*0;
    e12(jj,:) = muE(jj,:);    
    for t=2:13
        e12(:,:,t) = (lbdw*e12(:,:,t-1)*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*e12(:,:,t-1)*Pz)).*(1-sep_) + fbar*muE.*repmat(kron(u12(:,:,t-1)*Pe,(vj.*p0f')/V),Nw,1)./sum(muE);
        u12(:,:,t) = (sum((lbdw*e12(:,:,t-1)*Pz).*sep_ + (fw.*sum((1-lbdw)*e12(:,:,t-1)*Pz)).*sep_))*kron(eye(Ne),ones(Nf,1)) + (1-fbar)*(u12(:,:,t-1)*Pe);
        
        tol_ = abs(sum(sum(sum(e12(:,:,t))))/sum(muE(jj,:))+sum(sum(sum(u12(:,:,t))))/sum(muE(jj,:))-1);
        if tol_>1e-5
            warning(['do not add up to one jj:',num2str(jj),' t:',num2str(t),' tol:',num2str(tol_)])
        end
        w0_change(t-1) = w0_change(t-1)+sum(e12(jj,:,t));
        E_level(t-1)   = E_level(t-1)+sum(sum(e12(:,:,t)));
    end
    sep12_w(jj) = sum(sum(sum(u12(:,:,end))))/sum(muE(jj,:));
    w_change12(Nw+1-jj:2*Nw-jj) = w_change12(Nw+1-jj:2*Nw-jj)'+sum(e12(:,:,end),2);
    end
end

Survival = muE(:,:);
for t=2:13
    Survival(:,:,t) = (lbdw*Survival(:,:,t-1)*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*Survival(:,:,t-1)*Pz)).*(1-sep_);    
end
wage_growth = zeros(12,1);
for tt=2:13
wage_growth(tt-1) = 100*((sum(sum(Survival(:,:,tt),2).*wvec)/sum(sum(Survival(:,:,tt))))/(sum(sum(Survival(:,:,1),2).*wvec)/sum(sum(Survival(:,:,1))))-1);
end

figure
plot(1:12,wage_growth)
xlabel('horizon')
ylabel('Wage growth')
title('Wage growth for the Continuously Employed')

figure
plot(1:12,w0_change./E_level)
hold on,plot(1:12,lbdw.^(1:12))
xlabel('horizon')
ylabel('Fraction')
legend('observed','calvo^h')
title('fraction of 0 wage changes')


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

figure
plot(log(wvec),sep12_w*100,'*')
hold on
plot(log(wvec),sep12_wfit*100,'-')

title('Probability of unemployment in 12 periods')
xlabel('log wage')
ylabel('separation')
yyaxis right
plot(log(wvec),sum(muE,2))
ylabel('distribution')
legend('Conditional','fit','distribution')

% Probability of being unemployment at horizon h
E_h = muE;
U_h = 0*muU;
for h=2:24
    E_h(:,:,h) = (lbdw*E_h(:,:,h-1)*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*E_h(:,:,h-1)*Pz)).*(1-sep_) + fbar*muE.*repmat(kron(U_h(:,:,h-1)*Pe,(vj.*p0f')/V),Nw,1)./sum(muE);
    U_h(:,:,h) = (sum((lbdw*E_h(:,:,h-1)*Pz).*sep_ + (fw.*sum((1-lbdw)*E_h(:,:,h-1)*Pz)).*sep_))*kron(eye(Ne),ones(Nf,1)) + (1-fbar)*(U_h(:,:,h-1)*Pe);
end
figure
subplot(1,2,1), plot(0:23,squeeze(sum(sum(E_h,1),2))/sum(muE(:)));
title('Prob of employment at h')
xlabel('h')
subplot(1,2,2), plot(0:23,squeeze(sum(sum(U_h,1),2))/sum(muE(:)));
title('Prob of unemployment at h')
xlabel('h')

figure
subplot(1,2,1), plot(log(wvec),sep_by_w), title('separation by wage')
xlabel('log(wage)')
ylabel('separation probability')
yyaxis right
plot(log(wvec),sum(muE,2))
ylabel('distribution')

subplot(1,2,2), plot(sep_by_tenure), title('separation by tenure')
xlabel('tenure')
ylabel('separation probability')

figure
subplot(1,2,1), plot(Jcont), title('Jcont')
subplot(1,2,2), plot(Wcont), title('Wcont')

figure
plot(sep_), title('Separations')

figure
title('Productivity distribution')
plot(log(evecx),muU/sum(muU(:)))
hold on
plot(log(evecx),sum(muE*kron(eye(Ne),ones(Nf,1)))/sum(muE(:)))
plot(log(evecx),p0e)
legend('unemployed','employed','unconditional')
xlabel('log(ze)')



%% Macro regression

% Separations between t, and t+h
hh           = 12;
sep12_sector = zeros(Nw,Nf,hh-1);
TFP_sector   = zeros(Nw,Nf,hh);
wage_sector  = zeros(Nw,Nf,hh);
e_sector     = zeros(Nw,Nf,hh);
e_sectora    = zeros(Nw,Nf,hh);

sep_q  = zeros(Nw,Nf,hh/3);
wage_q = zeros(Nw,Nf,hh/3);
tfp_q  = zeros(Nw,Nf,hh/3);
e_q    = zeros(Nw,Nf,hh/3);
e_qa   = zeros(Nw,Nf,hh/3);

aux    = kron(eye(hh/3),ones(3,1));
for jj=1:Nf    
    
    pp_              = 0*p0f;
    pp_(jj)          = p0f(jj);
    e12              = muE*0;
    u12              = muU*0;
    e12(:,jj:Nf:end) = muE(:,jj:Nf:end);
    e12a             = e12;

    TFP_sector(:,jj,1)  = sum(zvec'.*e12,2);
    wage_sector(:,jj,1) = sum(wvec.*e12,2);
    e_sector(:,jj,1)    = sum(e12,2);    
    e_sectora(:,jj,1)   = sum(e12a,2);    
    for t=2:hh
        e12(:,:,t)  = (lbdw*e12(:,:,t-1)*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*e12(:,:,t-1)*Pz)).*(1-sep_); 
        e12a(:,:,t) = (lbdw*e12a(:,:,t-1)*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*e12a(:,:,t-1)*Pz)).*(1-sep_) + fbar*muE.*repmat(kron(muU*Pe,(vj.*(pp_'*Pf^(t-1)))/V),Nw,1)./sum(muE);
        
        sep12_sector(:,jj,t) = sum((lbdw*e12(:,:,t-1)*Pz).*sep_ + (fw.*sum((1-lbdw)*e12(:,:,t-1)*Pz)).*sep_,2);
        TFP_sector(:,jj,t)   = sum(zvec'.*e12a(:,:,t),2);
        wage_sector(:,jj,t)  = sum(wvec.*e12a(:,:,t),2);
        e_sector(:,jj,t)     = sum(e12(:,:,t),2);
        e_sectora(:,jj,t)    = sum(e12a(:,:,t),2);
    end        

    sep_q(:,jj,:)  = squeeze(sep12_sector(:,jj,:))*aux;
    wage_q(:,jj,:) = squeeze(wage_sector(:,jj,:))*aux;
    tfp_q(:,jj,:)  = squeeze(TFP_sector(:,jj,:))*aux;
    e_q(:,jj,:)    = squeeze(e_sector(:,jj,:))*aux;
    e_qa(:,jj,:)   = squeeze(e_sectora(:,jj,:))*aux;
end    

yy_        = reshape(log(sep_q(:,:,2)./e_q(:,:,1)),[],1);
xx_        = [kron(eye(Nf),ones(Nw,1)) reshape(log(wage_q(:,:,1)./e_qa(:,:,1)),[],1) reshape(log(tfp_q(:,:,1)./e_qa(:,:,1)),[],1)];
WW_        = (reshape(e_q(:,:,1),[],1));

index_ = (~isnan(yy_) & ~isinf(yy_) & sum(isnan(xx_),2)==0 & sum(isinf(xx_),2)==0);
yy_    = yy_(index_);
xx_    = xx_(index_,:);
WW_    = diag(WW_(index_));

beta_macro_sep_rate = (xx_'*WW_*xx_)\(xx_'*WW_*yy_)



yy_        = reshape(log(sep_q(:,:,2)),[],1);
xx_        = [kron(eye(Nf),ones(Nw,1)) reshape(log(wage_q(:,:,1)./e_qa(:,:,1)),[],1) reshape(log(tfp_q(:,:,1)./e_qa(:,:,1)),[],1)];
WW_        = (reshape(e_q(:,:,1),[],1));

index_ = (~isnan(yy_) & ~isinf(yy_) & sum(isnan(xx_),2)==0 & sum(isinf(xx_),2)==0);
yy_    = yy_(index_);
xx_    = xx_(index_,:);
WW_    = diag(WW_(index_));

beta_macro_sep = (xx_'*WW_*xx_)\(xx_'*WW_*yy_);


yy_        = reshape(log(tfp_q(:,:,2)./e_qa(:,:,2)),[],1) ;
xx_        = [kron(eye(Nf),ones(Nw,1)) reshape(log(wage_q(:,:,1)./e_qa(:,:,1)),[],1) reshape(log(sep_q(:,:,1)./e_q(:,:,1)),[],1)];
WW_        = (reshape(e_q(:,:,1),[],1));

index_ = (~isnan(yy_) & ~isinf(yy_) & sum(isnan(xx_),2)==0 & sum(isinf(xx_),2)==0);
yy_    = yy_(index_);
xx_    = xx_(index_,:);
WW_    = diag(WW_(index_));

beta_macro_prod = (xx_'*WW_*xx_)\(xx_'*WW_*yy_);


%% Table 
variable1 = {'Unemployment rate' 
             'Total separation rate'
             'Quit rate'
             'Fire rate'
             'Efficient separation rate' 
             'Exogenous separations'
             'Micro reg (linear)'
             'Micro reg(logit)'
             'Check_separations' 
             'Replacement rate'             
             'Macro sep reg wage (rate)'
             'Macro sep reg tfp (rate)'
             'Macro prod reg wage (rate)'
             'Macro prod reg sep (rate)'};
variable2 = [round([unemployment, sep_rate, quit_rate, end_sep_rate, dsep_rate, exo_sep_rate]*100,2),beta_linear(2),beta_logit(2),check_sep, replacement_wage, beta_macro_sep_rate(end-1), beta_macro_sep_rate(end),beta_macro_prod(end-1),beta_macro_prod(end)]; 
%variable3 = {'Option 1', 'Option 2', 'Option 3'};
 
% Create the table 
%myTable = table(variable1, variable2', 'VariableNames', {'Variable ', ' '});
myTable = table(variable1, variable2');
% Display the table with title 
disp('My Data Table'); 
disp(myTable); 

%%
% w0_change = zeros(Nw,Nf);
% wp_change = zeros(Nw,Nf);
% wn_change = zeros(Nw,Nf);
% for ii=1:Nf
%     ii
%     for jj=1:Nw
%         e12 = muE*0;
%         u12 = muU*0;
%         e12(jj,ii:Nf:end) = muE(jj,ii:Nf:end);
%         for t=2:13
%             e12(:,:,t) = (lbdw*e12(:,:,t-1)*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*e12(:,:,t-1)*Pz)).*(1-sep_);            
%         end
%         w0_change(jj,ii) = sum(e12(jj,:));
%         wn_change(jj,ii) = sum(sum(e12(1:jj-1,:)));
%         wp_change(jj,ii) = sum(sum(e12(jj+1:end,:)));
%     end
% end
% 
% wr_s1 = sum(w0_change)./sum(w0_change+wn_change+wp_change);
% wr_s2 = sum(w0_change)./sum(w0_change+wn_change);