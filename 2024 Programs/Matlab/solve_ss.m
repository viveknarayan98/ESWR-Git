
%---initial guess
%-firm values and policies
JF  = 0*ones(NS,1);             % value of  match
WF  = 0*ones(NS,1);             % value of a worker
UF  = 0*ones(NS,1);             % value of unemp

if loadSS_VF == 1
    load SSguessVF
end
EMF = 0*ones(NS,1);

eF = 189*ones(NS,1);
nF = 189*ones(NS,1);

%---compute z0: break even z value
iz0 = 189*ones(1,1); z0 = 189*ones(1,1);
iw0 = 189*ones(1,1); w0 = 189*ones(1,1);
ix0 = 189*ones(1,1); x0 = 189*ones(1,1);
iS0 = 189*ones(1,1); S0 = 189*ones(1,1);
iS0(:) = 48; %guess

iz0 = find(zvec(:,1)>= 0.65*muaz(1,1),1,'first');
z0  = zvec(iz0,1);

w0 = (1-thta)*(z0*xvec(1)) + thta*b_bar*z0;
iw0= vsearchprm(w0,wvec,wvprm);
iS0 = iw0 + (iz0-1)*Nw;

%---wages and profits
iwst  = 189*ones(NS,1);  iSst  = 189*ones(NS,1);
PROF  = 189*ones(NS,1);


%% iteration

Jnew = 189*ones(NS,1);
Wnew = 189*ones(NS,1);   
Unew = 189*ones(NS,1);

errJ = 189*ones(NS,1);
errW = 189*ones(NS,1);
errU = 189*ones(NS,1);

v0 = zeros(NS,1);

maxitH = 10000; tolH = 1e-8; wwTH = 0.35;
wwJ = 0.35; wwW = 0.35; wwU = 0.35;
showH = 0;
for itH = 1:maxitH
    %----------------------------------------------------------------------------------
    %---step 1: compute implied policies

        %---firm's policies 
        Jx = JF(:,1); J0x = max(Jx,v0);
        
        ex  = PR_xtoy(v0,Jx,rhoJ0); % firing decision
        EMx = E_xtoy(Jx,v0,rhoJ0); 
        
        eF(:,1)  = ex;
        EMF(:,1) = EMx;
        
        %---worker's policies 
        Wx = WF(:,1);
        Ux = UF(:,1);  % 
        
        Whx = (1-ex).*Wx  + ex.*Ux; % Continuation value
        
        Hx = E_xtoy(Whx,Ux,rhoWhU);  % Expected value of W    
        nx = PR_xtoy(Ux,Whx,rhoWhU); %quiting decision

        WhF(:,1)  = Whx;
        HF(:,1)  = Hx;      
        nF(:,1)  = nx;
        
        iS0x = iS0;  iw0x = iw0;  w0x = w0;
        W0x  = Wx(iS0x) + (w0x-wvec(iw0x)) * (Wx(iS0x+1) - Wx(iS0x))/(wvec(iw0x+1)-wvec(iw0x)); 
        W0F = W0x;
    
    %----------------------------------------------------------------------------------
    %---step 2: compute expectations    
    EXM = 0*ones(NS,1);  EXMst = 0*ones(NS,1);
    %EHa  = 0*ones(NS,Ni);  EHast = 0*ones(NS,Ni);
    %EHi  = 0*ones(NS,Ni);
    %EU   = 0*ones(Ni,1);
        
    for iz_np = 1:Nz
        
        iS_np = wind + Nw*(iz_np-1);  % this is (w,z')
        
        %---RHS of J when no wage adjustment
        EXM(:,1) = EXM(:,1) + Pz(zind,iz_np).*(1-nF(iS_np,1)).*EMF(iS_np,1);
        
        %---RHS of J with wage adjustment
        %Find position of iz in SVec grid
%         ist  = Svec(iS,:)
%         iSst(iz_np,1);     % ist is S point st (z',w*(z'))
%         iwx = iwst(ist,1); % position on wvec
%         wsx = wvec(iwx); %grid value of w
%         XMxx = EMF(ist,1);
%         nxx =  nF(ist,1) ;  nxx = min(max(nxx,0),1);
%         EXMst(:,1) = EXMst(:,1) + Pz(zind,iz_np)*(1-nxx)*XMxx;
          EXMst(:,1)=0;

%         %---RHS for W when no wage adjustment
%         EHa(:,ii) = EHa(:,ii) + Paz(zind,iz_np,ii).*HaF(iS_np,ii);
%         
%         %---RHS of W with wage adjustment
%         ist  = iSst(iz_np,ii);     % ist is S point st (z',w*(z'))
%         wsax = wgest(ist,ii);
%         iwax = iwst(ist,ii); % position on wvec
%         Haxx = HaF(ist,ii) + (wsax-wvec(iwax)) * (HaF(ist+1,ii)-HaF(ist,ii))/(wvec(iwax+1)-wvec(iwax));        %corrected the index in wvec
%         
%         EHast(:,ii) = EHast(:,ii) + Paz(zind,iz_np,ii).*Haxx;
%         
%         
%         
%         %---RHS of U - may find another job
%         for ii_np = 1:Ni
%             EU(ii,1) = EU(ii,1) + pisU(ii,ii_np)*(fbar*XUF(ii,ii_np) + (1-fbar)*UF(ii)); %Added pisU
%         end
     end
    
    %----------------------------------------------------------------------------------
    %---step 3: update value functions
 
    Jnew(:,1) = PROF(:,1) + (1-dlta)*(beta*(lbdw*EXM(:,1) + (1-lbdw)*EXMst(:,1))); %includes exogenous separation here
    
    Wnew(:,1) = Svec(:,1);  %+ beta*(lbdw*EHa(:,ii) + (1-lbdw)*EHast(:,ii));
    
    Unew(:,1)   = b_bar*Svec(:,2)     ;%  + beta*EU(ii,1);
    
    %---errors
    errJ(:,1)   = Jnew(:,1)-JF(:,1);
    errW(:,1)   = Wnew(:,1)-WF(:,1);
    errU(:,1)   = Unew(:,1)  -UF(:,1);
    
    err = [max(abs(errJ(:))), max(abs(errW(:))), max(abs(errU(:)))];    
    
    
    %---update value functions 
    if showH < 0
        disp(['itH = ',num2str(itH),', err: [J, W, U] = [',num2str(err(1)),' , ',num2str(err(2)),', ',num2str(err(3)),']'])
        showH = 25;
        %disp(fiF_SS)
    end
    showH = showH - 1;
    
    if max(err) < tolH  % done
        disp(['itH = ',num2str(itH),', err: [J, W, U] = [',num2str(err(1)),' , ',num2str(err(2)),', ',num2str(err(3)),']'])
        disp('value functions converged')
        break
    else
        JF = wwJ*JF + (1-wwJ)*Jnew;
        WF = wwW*WF + (1-wwW)*Wnew;       
        UF = wwW*UF + (1-wwW)*Unew;
    end
    
    
end
save('SSguessVF','JF','WF','UF');

% %% compute measure
% 
% maxitmu = 5000; tolmu = 1e-12; wwmu = 0.05;  
% 
% %---measure for employed and unemployed
% Ne  = 2; % e = E, F
% muE = ones(Ne,NS,Ni); muE = muE/sum(muE(:)); muN = 0*ones(Ni,1);
% 
% if loadSS_mu == 1
%     load SSguessmu
% end
% 
% showmu = 1;
% for itmu = 1:maxitmu
%     %---Transition matrices
%     E_U = zeros(Ni,1); E_E = zeros (Ni,1); E_F = zeros(Ni,1);
%     F_U = zeros(Ni,1); F_E = zeros (Ni,1); F_F = zeros(Ni,1);
%     U_U = zeros(Ni,1); U_E = zeros (Ni,1); U_F = zeros(Ni,1);
%     muEnew = 0*ones(Ne,NS,Ni);  muNnew = 0*ones(Ni,1);
%     for ii = 1:Ni
%         %---transitions from E to x
%         for iS = 1:NS
%             for iz_np = 1:Nz
%                 %------------------------------------------------------------------------------------------------------------------------------------
%                 %---no wge adjust
%                 iS_np = wind(iS) + Nw*(iz_np-1);  % this is (w,z')
%                 
%                 %---E to E 
%                 muEnew(1,iS_np,ii) = muEnew(1,iS_np,ii) + lbdw*Paz(zind(iS),iz_np,ii)*(1-naF(iS_np,ii))*(1-eaF(iS_np,ii)) *(1.0-dF(iS_np,ii))* muE(1,iS,ii);
%                 E_E(ii,1) = E_E(ii,1)+ + lbdw*Paz(zind(iS),iz_np,ii)*(1-naF(iS_np,ii))*(1-eaF(iS_np,ii)) *(1.0-dF(iS_np,ii))* muE(1,iS,ii);
%                 
%                 %---E to F 
%                 muEnew(2,iS_np,ii) = muEnew(2,iS_np,ii) + lbdw*Paz(zind(iS),iz_np,ii)*(1-naF(iS_np,ii))*(1-eaF(iS_np,ii)) *  (dF(iS_np,ii))  * muE(1,iS,ii);
%                 E_F(ii,1) =  E_F(ii,1) + lbdw*Paz(zind(iS),iz_np,ii)*(1-naF(iS_np,ii))*(1-eaF(iS_np,ii)) *  (dF(iS_np,ii))  * muE(1,iS,ii);
%                 %---E to U
%                 muNnew(ii)   = muNnew(ii)    + lbdw*Paz(zind(iS),iz_np,ii) *(naF(iS_np,ii) + (1-naF(iS_np,ii))*eaF(iS_np,ii)) *muE(1,iS,ii);
%                 E_U(ii,1) = E_U(ii,1) + lbdw*Paz(zind(iS),iz_np,ii) *(naF(iS_np,ii) + (1-naF(iS_np,ii))*eaF(iS_np,ii)) *muE(1,iS,ii);
%                 %------------------------------------------------------------------------------------------------------------------------------------
%                 
%                 
%                 
%                 %------------------------------------------------------------------------------------------------------------------------------------
%                 %---wge adjust 
%                 z_ax = zvec(iz_np,1);
%                 pi_ax = omega(1)*(z_ax-co(ii));
%                 for jj = 2:Nweight
%                     sum_rho = 0;
%                     for nn = 0:jj-2
%                         sum_rho = sum_rho + rho_z^(nn);
%                     end
%                     z_ax = (1-rho_z)* exp(mu_bar(ii)) * sum_rho + rho_z^(jj-1)*zvec(iz_np,1);
%                     pi_ax  = pi_ax + omega(jj)*(z_ax-co(ii));
%                 end
%                 pi_ax = pi_ax/sum(omega);              
%                 wsax  = (1-thta)*pi_ax + thta*b_ave(ii); %MODEL IMPLIED WAGE GIVEN Z
%                 
% %                 if (wsax > zvec(iz_np,1)-co(ii))
% %                     wsax = zvec(iz_np,1)-co(ii);%full surplus
% %                 end
%                 wsax  = min( max(wsax,wmin) , wmax);
%                 iwstx = vsearchprm(wsax,wvec,wvprm); % Find in WVEC the position of w(z)model
%                 ist   = iwstx + (iz_np-1)*Nw;     %Find in SVEC the position of (w(z),z)
%                 
%                 dw   = (wsax - wvec(iwstx))/(wvec(iwstx+1) - wvec(iwstx));
%                 
%                 % S' in [ist, ist+1]
%                 %---E to E 
%                 pxst   = (1-naF(ist,ii)  )*(1-eaF(ist  ,ii)) *(1.0-dF(ist  ,ii));
%                 pxstp1 = (1-naF(ist+1,ii))*(1-eaF(ist+1,ii)) *(1.0-dF(ist+1,ii));                
%                 px     = (1-dw)*pxst  + dw*pxstp1;
%                 px     = max( min(px,1) , 0);
%                 
%                 muEnew(1,ist  ,ii) = muEnew(1,ist,ii)   + (1-dw)*(1-lbdw)*Paz(zind(iS),iz_np,ii)*px* muE(1,iS,ii);
%                 muEnew(1,ist+1,ii) = muEnew(1,ist+1,ii) +   dw  *(1-lbdw)*Paz(zind(iS),iz_np,ii)*px* muE(1,iS,ii);
%                 E_E(ii,1) = E_E(ii,1) + (1-dw)*(1-lbdw)*Paz(zind(iS),iz_np,ii)*px* muE(1,iS,ii);
%                 E_E(ii,1) = E_E(ii,1) +   dw  *(1-lbdw)*Paz(zind(iS),iz_np,ii)*px* muE(1,iS,ii);
%                 %---E to F 
%                 pxst   = (1-naF(ist,ii)  )*(1-eaF(ist  ,ii)) *dF(ist  ,ii);
%                 pxstp1 = (1-naF(ist+1,ii))*(1-eaF(ist+1,ii)) *dF(ist+1,ii);                
%                 px     = (1-dw)*pxst  + dw*pxstp1;
%                 px     = max( min(px,1) , 0);
%                 
%                 muEnew(2,ist  ,ii) = muEnew(2,ist  ,ii) + (1-dw)*(1-lbdw)*Paz(zind(iS),iz_np,ii)* px  * muE(1,iS,ii);
%                 muEnew(2,ist+1,ii) = muEnew(2,ist+1,ii) +   dw  *(1-lbdw)*Paz(zind(iS),iz_np,ii)* px  * muE(1,iS,ii);
%                 E_F(ii,1)= E_F(ii,1) + (1-dw)*(1-lbdw)*Paz(zind(iS),iz_np,ii)* px  * muE(1,iS,ii);
%                 E_F(ii,1)= E_F(ii,1) +   dw  *(1-lbdw)*Paz(zind(iS),iz_np,ii)* px  * muE(1,iS,ii);
%                 %---E to u                
%                 pxst   = (naF(ist,ii)   + (1-naF(ist,ii)  )*eaF(ist,ii));
%                 pxstp1 = (naF(ist+1,ii) + (1-naF(ist+1,ii))*eaF(ist+1,ii));
%                 px     = (1-dw)*pxst  + dw*pxstp1;
%                 px     = max( min(px,1) , 0);
%                 
%                 muNnew(ii) = muNnew(ii)    + (1-dw)*(1-lbdw)* Paz(zind(iS),iz_np,ii) *px *muE(1,iS,ii);
%                 muNnew(ii) = muNnew(ii)    +   dw  *(1-lbdw)* Paz(zind(iS),iz_np,ii) *px *muE(1,iS,ii);     
%                 E_U(ii,1) = E_U (ii,1) + (1-dw)*(1-lbdw)* Paz(zind(iS),iz_np,ii) *px *muE(1,iS,ii);
%                 E_U(ii,1) = E_U (ii,1) +   dw  *(1-lbdw)* Paz(zind(iS),iz_np,ii) *px *muE(1,iS,ii);
%             end
%         end
%         
%         %---transitions from F to x
%         for iS = 1:NS
%             for iz_np = 1:Nz
%                 %------------------------------------------------------------------------------------------------------------------------------------
%                 %---no wge adjust
%                 iS_np = wind(iS) + Nw*(iz_np-1);  % this is (w,z')
%                 
%                 %---F to E 
%                 muEnew(1,iS_np,ii) = muEnew(1,iS_np,ii) + (1-fiF(iS_np,ii))*Piz(zind(iS),iz_np,ii)*(1-niF(iS_np,ii))*(1-eiF(iS_np,ii))* (rF(iS_np,ii))  *muE(2,iS,ii);
%                 F_E(ii,1) = F_E(ii,1) +  (1-fiF(iS_np,ii))*Piz(zind(iS),iz_np,ii)*(1-niF(iS_np,ii))*(1-eiF(iS_np,ii))* (rF(iS_np,ii))  *muE(2,iS,ii);
%                 %---F to F
%                 muEnew(2,iS_np,ii) = muEnew(2,iS_np,ii) + (1-fiF(iS_np,ii))*Piz(zind(iS),iz_np,ii)*(1-niF(iS_np,ii))*(1-eiF(iS_np,ii))*(1.0-rF(iS_np,ii))*muE(2,iS,ii);                
%                 F_F(ii,1) =  F_F(ii,1) + (1-fiF(iS_np,ii))*Piz(zind(iS),iz_np,ii)*(1-niF(iS_np,ii))*(1-eiF(iS_np,ii))*(1.0-rF(iS_np,ii))*muE(2,iS,ii);  
%                 %---F to U
%                 muNnew(ii)   = muNnew(ii) + (1-fiF(iS_np,ii))*Piz(zind(iS),iz_np,ii)*(niF(iS_np,ii)+(1-niF(iS_np,ii))*eiF(iS_np,ii))*muE(2,iS,ii);                
%                 F_U(ii,1) =  F_U(ii,1) + (1-fiF(iS_np,ii))*Piz(zind(iS),iz_np,ii)*(niF(iS_np,ii)+(1-niF(iS_np,ii))*eiF(iS_np,ii))*muE(2,iS,ii); 
%                 %---F to E --> due to finding
%                 for ii_np = 1:Ni
%                     muEnew(1,iS0(ii_np),ii_np) = muEnew(1,iS0(ii_np),ii_np) + fiFinp(iS_np,ii,ii_np)*Piz(zind(iS),iz_np,ii)*muE(2,iS,ii);
%                     F_E(ii_np,1) =  F_E(ii_np,1) + fiFinp(iS_np,ii,ii_np)*Piz(zind(iS),iz_np,ii)*muE(2,iS,ii);
%                 end
%                 
%                 %------------------------------------------------------------------------------------------------------------------------------------
%             end 
%         end
%         
%         
%         %---transitions from U to x
%         %---U to E
%         for ii_np = 1:Ni
%             muEnew(1,iS0(ii_np),ii_np) = muEnew(1,iS0(ii_np),ii_np) + fUFinp(ii,ii_np)*muN(ii);  % fbar(ii) = fbar in steady-state       
%             U_E(ii_np,1) =  U_E(ii_np,1) + fUFinp(ii,ii_np)*muN(ii);
%         end
%         
%         %---U to U
%         muNnew(ii) = muNnew(ii) + (1-fUF(ii))*muN(ii);
%         U_U(ii,1) =  U_U(ii,1) + (1-fUF(ii))*muN(ii);
%     end
%     
%     %---error and update
%     errmuE = max(abs(muEnew(:) - muE(:)));
%     errmuN = max(abs(muNnew - muN));
%     
%     disp(['itmu = ',num2str(itmu),', err: [E, N] = [',num2str(errmuE),' , ',num2str(errmuN),']'])
%     if showmu < 0
%         disp(['itmu = ',num2str(itmu),', err: [E, N] = [',num2str(errmuE),' , ',num2str(errmuN),']'])
%         showmu = 5;
%     end
%     showmu = showmu - 1;
%     
%     if ((errmuE < tolmu) && (errmuN < tolmu))
%         disp(['itmu = ',num2str(itmu),', err: [E, N] = [',num2str(errmuE),' , ',num2str(errmuN),']'])
%         disp('measure converged')
%         break
%     else                
%         muE = wwmu*muE + (1-wwmu)*muEnew;
%         muN = wwmu*muN + (1-wwmu)*muNnew;
%         % muN = muN/sum(1-muE(:));
%     end
%     
% end
% save('SSguessmu','muE','muN');
% 
% %%% Calculate implied kappa
% %---compute measures
% %1) Total number of searchers
% Nsearch=0*ones(Ni,1);
% for ii=1:Ni
%     for iit=1:Ni
%         %Nsearch(ii) = Nsearch(ii) + (pisU(iit,ii)*muN(iit)) + (pisF(iit,ii)*sum(muE(2,:,iit)));
%         Nsearch(ii) = Nsearch(ii) + (pisU(iit,ii)*muN(iit)) + (pisF(iit,ii)*effF*sum(muE(2,:,iit)));
%     end
% end
% 
% %2) Number of matches formed with U workers: M_0
% MUsearch=0*ones(Ni,1);
% for ii=1:Ni
%     for iit=1:Ni
%         MUsearch(ii)= MUsearch(ii) + pisU(iit,ii)*pUtoW(iit,ii)*muN(iit);
%     end
% end
% 
% %3) Number of matches formed with F workers: M_F
% MFsearch=0*ones(Ni,1);
% for ii = 1:Ni
%     for iS = 1:NS
%         for iit = 1:Ni
%             %MFsearch(ii) = MFsearch(ii) + pisF(iit,ii)*pFtoW(iS,iit,ii)*muE(2,iS,iit);
%             MFsearch(ii) = MFsearch(ii) + pisF(iit,ii)*pFtoW(iS,iit,ii)*effF*muE(2,iS,iit);
%         end
%     end
% end
%     
% pfacc = (MUsearch+MFsearch)./Nsearch;
% n_bar(:)   = Nsearch(:);
% %% Free entry
% ii = 1;
% kppa = qbar*(max(JF(iS0(ii),ii),0))*pfacc(ii); % ((sum(MFsearch(:,ii))+MUsearch(ii))/Nsearch(ii)));
% 
% %% compute implied psi
% 
% tight    = fbar/qbar;
% psibar  = qbar/( (1+(tight^gma))^(-1/gma) );
% fhat    = psibar*tight* ((1+(tight^gma))^(-1/gma));
% th_bar=tight;
% 
% %% Results
% UIxi_bar = 0*ones(Ni,1);
% %---unemployment
% U_bar  = sum(muN(:));
% mf = muE(2,:,:); I_bar = sum(mf(:));
% UI_bar = U_bar + I_bar;
% for ii = 1:Ni
%     UIxi_bar(ii)=muN(ii)+sum(muE(2,:,ii));
% end
% 
% %---output and employemnt
% emp_bar = 0; empxi_bar = 0*ones(Ni,1);
% Y_bar   = 0; Yxi_bar   = 0*ones(Ni,1);
% wg_bar  = 0; wgxi_bar  = 0*ones(Ni,1);
% tc_bar  = 0; tcxi_bar  = 0*ones(Ni,1);
% zmn_bar = 0; zmnxi_bar = 0*ones(Ni,1);
% ALPxi_bar = 0*ones(Ni,1);
% for ii = 1:Ni    
%     
%     %---employment
%     mm = muE(1,:,ii); 
%     empxi_bar(ii) = sum(mm(:));
%     emp_bar       = emp_bar + empxi_bar(ii);
%     
%     %---output
%     yy = Svec(:,2).*(muE(1,:,ii)'); 
%     Yxi_bar(ii) = sum(yy(:));  
%     Y_bar       = Y_bar   + Yxi_bar(ii);
%     
%     %---wages
%     
%     %wge = thtab*alpha*Y(:,ii) + (1-thtab)*b_bar;
%     wge = wgest(:,ii);
%     ww = wge.*(muE(1,:,ii)'); %This tells you total wages paid in sector ii
%     wgxi_bar(ii) = sum(ww(:));
%     wg_bar       = wg_bar + wgxi_bar(ii);
%     
%     %---ALP
%     ALPxi_bar(ii) = Yxi_bar(ii)/empxi_bar(ii);
%     
%     %---z mean
%     yy = Y(:,ii); mm = squeeze(muE(1,:,ii))'; zz = yy.*mm;
%     
%     zmnxi_bar(ii) = sum(zz(:))/sum(mm(:));
%     zmn_bar       = zmn_bar + sum(zz(:));
% end
% 
% wg_bar  = wg_bar/emp_bar; %These are average wages
% ALP_bar = Y_bar/emp_bar;
% zmn_bar = zmn_bar/emp_bar;
% for ii=1:Ni
%     %Average wages: Total wage bill/employment
%     wgxi_bar(ii)=wgxi_bar(ii)/empxi_bar(ii);
% end 
% 
% %Fiscal cost
% UI_cost_bar=0*ones(Ni,1);
% s_cost_bar=0*ones(Ni,1);
% for ii = 1:Ni
%     %Updated
%     UI_cost_bar(ii)=b_bar*(muN(ii)+sum(muE(2,:,ii)));
% end 
% 
% %% Save Steady State outcomes
% %Stocks: U, UI, Emp
% %Flows: EU, EE, EF, UE,UU, FU, FF,FE
% totE = E_E+E_U+E_F;
% totU = U_E+U_U;
% totF = F_E+F_U+F_F;
% 
% E_U = E_U./totE;
% E_E = E_E./totE;
% E_F = E_F./totE;
% 
% F_U = F_U./totF;
% F_E = F_E./totF;
% F_F = F_F./totF;
% 
% U_U = U_U./totU;
% U_E = U_E./totU;
% 
% %recall
% %Numerator: measure of recalled workers from F in sector 1
% rworkers = sum(rF(:,1).*muE(2,:,1)');
% %Denominator: totF
% recall=rworkers/totF(1,1);
% rshare=recall/F_E(1,1);
% 
% %Replacement ratio
% b_w=b_bar/wvec(iw0(1));
% %Profit share
% 
% pi_share=wvec(iw0(1))/(zvec(iz0(1)));
% 
% %Welfare SS
% Cons_welf   = zeros(Ni,1);
% Firm_welf   = zeros(Ni,1);
% PDVC        = zeros(Ni,1);
% PDVP        = zeros(Ni,1);
% PDVP_norm   = zeros(Ni,1);
% 
% for ii=1:Ni
%     Cons_welf(ii) = sum(WF(:,ii)'.* muE(1,:,ii))+ sum(FF(:,ii)'.* muE(2,:,ii))+ UF(ii)* muN(ii);
%     Firm_welf(ii) = sum(JF(:,ii)'.* muE(1,:,ii))+ sum(VF(:,ii)'.* muE(2,:,ii));
%     %Just pure consumption, using wgest
%     PDVC(ii)      = sum(wgest(:,ii)'.* muE(1,:,ii))+ sum(b_bar.* muE(2,:,ii))+ b_bar* muN(ii);
%     PDVP(ii)      = sum(PROF(:,ii)'.* muE(1,:,ii)) + sum(-ci(ii).* muE(2,:,ii));
%     %Normalize by the measure of firms
%     PDVP_norm(ii) = (sum(PROF(:,ii)'.* muE(1,:,ii)) + sum(-ci(ii).* muE(2,:,ii)))/(sum(muE(1,:,ii))+sum(muE(2,:,ii)));
% end
% Net_C_welf = sum(Cons_welf)- sum(UI_cost_bar);
% Net_F_welf = sum(Firm_welf)- sum(UI_cost_bar);
% Net_PDVC   = sum(PDVC)- sum(UI_cost_bar);
% Net_PDVP   = sum(PDVP)- sum(UI_cost_bar);
% sumPDVC    = sum(PDVC);
% sumPDVP    = sum(PDVP);
% sumPDVP_norm=sum(PDVP_norm);
% 
% sfile = 'SSresults';
% save(sfile,'U_bar','I_bar','UI_bar','Y_bar', 'UIxi_bar','empxi_bar','b_w','pi_share', 'E_U', 'E_E','E_F','F_U', 'F_E','F_F','U_U','U_E','Net_C_welf', 'Net_F_welf', 'Net_PDVC', 'Net_PDVP', 'sumPDVC', 'sumPDVP', 'sumPDVP_norm')
