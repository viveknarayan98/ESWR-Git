%% ------------------------------------------------------------------------
% OtherStats.m: Computes other post equilibrium statistics
% -------------------------------------------------------------------------
% Wage Rigidity, Endogenous Separations, and Labor productivity
% Joaquin Garcia-Cabo, Camilo Morales-Jimenez, Vivek Naranyan
% -------------------------------------------------------------------------
% This version: Spring 2025
% -------------------------------------------------------------------------



%% ------------------------------------------------------------------------
% Probability of being unemployment at horizon h
% -------------------------------------------------------------------------
E_h = muE;
U_h = 0*muU;
for h=2:24
    E_h(:,:,h) = (lbdw*RECURSEMAT*E_h(:,:,h-1)*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*RECURSEMAT*E_h(:,:,h-1)*Pz)).*(1-sep_) + fbar*(lbdw_n*fw + (1-lbdw_n)*fw_rigid).*(1-sep_).*repmat(kron(U_h(:,:,h-1)*Pe,(vj.*p0f')/V),Nw,1);
    U_h(:,:,h) = (sum((lbdw*RECURSEMAT*E_h(:,:,h-1)*Pz).*sep_ + (fw.*sum((1-lbdw)*RECURSEMAT*E_h(:,:,h-1)*Pz)).*sep_))*kron(eye(Ne),ones(Nf,1)) + (1-fbar)*(U_h(:,:,h-1)*Pe) + sum(fbar*(lbdw_n*fw + (1-lbdw_n)*fw_rigid).*sep_.*repmat(kron(U_h(:,:,h-1)*Pe,(vj.*p0f')/V),Nw,1))*kron(eye(Ne),ones(Nf,1));
end


%% ------------------------------------------------------------------------
% Macro regression
% -------------------------------------------------------------------------

F0 = cumsum(p0f);

% Separations between t, and t+h
bb_          = 100;    % Burn in
hh           = 300;    % Horizon
Nchain       = 20;     % Number of chains
sep12_sector = zeros(Nw,Nchain,hh*3);
TFP_sector   = zeros(Nw,Nchain,hh*3);
wage_sector  = zeros(Nw,Nchain,hh*3);
e_sectora    = zeros(Nw,Nchain,hh*3);

sep_q  = zeros(Nw,Nchain,hh);
wage_q = zeros(Nw,Nchain,hh);
tfp_q  = zeros(Nw,Nchain,hh);
e_qa   = zeros(Nw,Nchain,hh);

parfor jj=1:Nchain   
%for jj=1:Nchain     
    [sep12_sector(:,jj,:),TFP_sector(:,jj,:), wage_sector(:,jj,:),e_sectora(:,jj,:), sep_q(:,jj,:), wage_q(:,jj,:), tfp_q(:,jj,:), e_qa(:,jj,:)]=chain_macro(jj,F0,hh,muE,zvec,wvec,Pf,Pe,vj,lbdw,RECURSEMAT,sep_,fw,fbar,lbdw_n,fw_rigid,muU,Nw);
end


SEP_  = squeeze(sum(sep_q));
EE_   = squeeze(sum(e_qa));
WAGE_ = squeeze(sum(wage_q))./EE_;
TFP_  = squeeze(sum(tfp_q))./EE_;
for jj=1:20
scatter(SEP_(jj,:),WAGE_(jj,:))
end 
YY_ = log(reshape(SEP_(:,bb_+2:end),[],1));
XX_ = [kron(ones(hh-bb_-1,1),eye(Nchain)) log(reshape(WAGE_(:,bb_+1:end-1),[],1)) log(reshape(TFP_(:,bb_+1:end-1),[],1))];
top = (XX_'*XX_);
bottom = (XX_'*YY_);
beta_macro_sep = (XX_'*XX_)\(XX_'*YY_);

YY_ = log(reshape(TFP_(:,bb_+2:end),[],1));
XX_ = [kron(ones(hh-bb_-1,1),eye(Nchain)) log(reshape(WAGE_(:,bb_+1:end-1),[],1)) log(reshape(SEP_(:,bb_+1:end-1),[],1))];

beta_macro_prod = (XX_'*XX_)\(XX_'*YY_);

