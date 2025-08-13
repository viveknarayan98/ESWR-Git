%% ------------------------------------------------------------------------
% Viter_.m: Value function iteration
% -------------------------------------------------------------------------
% Wage Rigidity, Endogenous Separations, and Labor productivity
% Joaquin Garcia-Cabo, Camilo Morales-Jimenez, Vivek Naranyan
% -------------------------------------------------------------------------
% This version: Spring 2025
% -------------------------------------------------------------------------

if exist('disp_e_','var')==0
    disp_e_=1;
end

% Initial guess for values
W_bar = b_bar*evecx';
Jaux  = thta*(zvec'-wvec)/(1-beta);
Uval  = (b_bar*evecx' + beta*fbar*W_bar)/(1-beta*(1-fbar));
Uaux  = kron(Uval,ones(1,Nf));
Waux  = (wvec)/(1-beta)+Uaux;

% Initial guess for distribution
muE = ones(Nw,Nz); 
muE = (1-uss)*muE/sum(muE(:)); 
muU = uss*p0e';

% Initialize
Jconto      = Jaux;
Wconto      = Waux;
check_      = 0;
iter_outer_ = 0;
rsmooth_    = 1;

while check_ == 0 & iter_outer_<max_out_loop
    DIFF_   = 10;
    iter_V  = 0;
    check_  = 0;
    fwbar_ = sum(muE,2)./sum(muE(:));
    while DIFF_>tol_Viter &  iter_V<m_viter_i+m_viter_a*(iter_outer_>0)

        % Compute the best wage possible
        Nash_              = (Jaux.^thta).*(Waux-Uaux).^(1-thta);
        Nash_(Jaux<0)      = -realmax;
        Nash_(Waux-Uaux<0) = -realmax;

        % Find optimal wage
        mN_ = max(Nash_);
        fw = exp((Nash_-mN_)/theta_w)./sum(exp((Nash_-mN_)/theta_w));

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

        % "Rigid wage for new hires"
        fw_rigid = fw(:,(pos_rigidl-1)*Nf+1:pos_rigidl*Nf)*ww_rigid_+fw(:,(pos_rigidu-1)*Nf+1:pos_rigidu*Nf)*(1-ww_rigid_);
        fw_rigid = repmat(fw_rigid,1,Ne);

        % Values given rigid wage for new hires
        Jrigid   = sum(fw_rigid.*Jaux.*(1-sep_));
        W_rigid = sum(fw_rigid.*(Waux.*(1-sep_)+Uaux.*sep_));

        % Value of a filled vacancy with a new hire
        avJ      = (lbdw_n*Jstar + (1-lbdw_n)*Jrigid)*kron(muU'/sum(muU(:)),eye(Nf));

        % Vacancies distribution
        vj  = (qbar*max(avJ,0)).^(1/chi);
        vj  = vj/(vj*p0f)*Vss;

        % Expected value of employment given vacancy distribution
        W_bar   = (lbdw_n*Wstar + (1-lbdw_n)*W_rigid)*kron(eye(Ne),(vj.*p0f')'/Vss);

        % New value of unemployment
        Unew  = b_bar*evecx' + beta*((1-fbar)*Uval + fbar*W_bar)*Pe';

        % Tolarance
        DIFF_ = [max(abs(Jcont(:)-Jconto(:)))    max(abs(Wcont(:)-Wconto(:)))    max(abs(Unew(:)-Uval(:)))];
        DIFF_ = max(abs(DIFF_(:)));

        % Update value funciton
        Jaux   = (1-smd_v_)*Jnew+smd_v_*Jaux;
        Waux   = (1-smd_v_)*Wnew+smd_v_*Waux;
        Uval   = (1-smd_v_)*Unew+smd_v_*Uval;
        Uaux   = kron(Uval,ones(1,Nf));

        % Update 
        Jconto = Jcont;
        Wconto = Wcont;
        iter_V = 1+iter_V;
        if iter_V==1 && DIFF_<=tol_Viter
            check_ = 1;
        end

    end

    % Compute ergodic distribution
    diffmu = 1;
    itermu = 0;
    while diffmu>tol_muiter & itermu<max_dist_iter

        muEnew  = (lbdw*RECURSEMAT*muE*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*RECURSEMAT*muE*Pz)).*(1-sep_) + fbar*(lbdw_n*fw + (1-lbdw_n)*fw_rigid).*(1-sep_).*repmat(kron(muU*Pe,(vj.*p0f')/Vss),Nw,1);
        muUnew  = (sum((lbdw*RECURSEMAT*muE*Pz).*sep_ + (fw.*sum((1-lbdw)*RECURSEMAT*muE*Pz)).*sep_))*kron(eye(Ne),ones(Nf,1)) + (1-fbar)*(muU*Pe) + sum(fbar*(lbdw_n*fw + (1-lbdw_n)*fw_rigid).*sep_.*repmat(kron(muU*Pe,(vj.*p0f')/Vss),Nw,1))*kron(eye(Ne),ones(Nf,1));

        diffmu = max(abs([muEnew(:);muUnew(:)]-[muE(:);muU(:)]));
        muE = muEnew;
        muU = muUnew;
        itermu = itermu+1;

        if itermu==1 %&& diffmu<=tol_muiter && check_==1
            check_ = 1;
        else
            check_ = 0;
        end

    end

    iter_outer_=iter_outer_+1;

    if disp_e_ == 1
        fprintf('\nValue iteration %4.7f. distribution %4.7f. Outerloop %4.0f. Loop V: %4.0f. Loop mu: %4.0f. Smooth: %1.3f',[DIFF_ diffmu iter_outer_ iter_V itermu smd_v_])
    end

    if iter_outer_>1 
        if DIFF_<DIFF_o && rsmooth_ == 1
            smd_v_ = smd_v_*p_smooth_;
        elseif DIFF_>DIFF_o
            smd_v_   = min(smd_v_/p_smooth_,0.95);
            rsmooth_ = 0;
        end
    end    

    DIFF_o = DIFF_;

    %sum(muU(:))    
    
end


if disp_e_ == 1
    fprintf('\n \n \n Equilibrium found... computing statistics... \n\n\n')
end
