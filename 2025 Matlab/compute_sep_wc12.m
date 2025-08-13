function [sep12_w, w_change12, w0_change, E_level] = compute_sep_wc12(jj,muE,muU,lbdw,RECURSEMAT,Pz,sep_,fw,fbar,lbdw_n,fw_rigid,Pe,vj,p0f,V,Nw,Ne,Nf)
    
    w_change12 = zeros(1,2*Nw-1);
    w0_change  = zeros(1,12);
    E_level    = zeros(1,12);

    e12       = muE*0;
    u12       = muU*0;
    e12(jj,:) = muE(jj,:);
    for t=2:13
        e12(:,:,t) = (lbdw*RECURSEMAT*e12(:,:,t-1)*Pz).*(1-sep_) + (fw.*sum((1-lbdw)*RECURSEMAT*e12(:,:,t-1)*Pz)).*(1-sep_) + fbar*(lbdw_n*fw + (1-lbdw_n)*fw_rigid).*(1-sep_).*repmat(kron(u12(:,:,t-1)*Pe,(vj.*p0f')/V),Nw,1);
    
        u12(:,:,t) = (sum((lbdw*RECURSEMAT*e12(:,:,t-1)*Pz).*sep_ + (fw.*sum((1-lbdw)*RECURSEMAT*e12(:,:,t-1)*Pz)).*sep_))*kron(eye(Ne),ones(Nf,1)) + (1-fbar)*(u12(:,:,t-1)*Pe) + sum(fbar*(lbdw_n*fw + (1-lbdw_n)*fw_rigid).*sep_.*repmat(kron(u12(:,:,t-1)*Pe,(vj.*p0f')/V),Nw,1))*kron(eye(Ne),ones(Nf,1));
    
        tol_ = abs(sum(sum(sum(e12(:,:,t))))/sum(muE(jj,:))+sum(sum(sum(u12(:,:,t))))/sum(muE(jj,:))-1);
        if tol_>1e-5
            warning(['do not add up to one jj:',num2str(jj),' t:',num2str(t),' tol:',num2str(tol_)])
        end
        w0_change(t-1) = w0_change(t-1)+sum(sum((lbdw*RECURSEMAT(:,jj)*e12(jj,:,t-1)*Pz).*(1-sep_)));
        E_level(t-1)   = E_level(t-1)+sum(sum(e12(:,:,t)));
    end
    sep12_w    = sum(sum(sum(u12(:,:,end))))/sum(muE(jj,:));
    w_change12 = w_change12(Nw+1-jj:2*Nw-jj)'+sum(e12(:,:,end),2);

end