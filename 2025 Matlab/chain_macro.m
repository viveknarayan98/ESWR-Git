function [sep12_sector,TFP_sector, wage_sector,e_sectora, sep_q, wage_q, tfp_q, e_qa] = chain_macro(jj,F0,hh,muE,zvec,wvec,Pf,Pe,vj,lbdw,RECURSEMAT,sep_,fw,qbar,lbdw_n,fw_rigid,muU,Nw)

    %fprintf('chain: %1.0f \n',jj)
    rng(123+jj)
    seq_ = rand(hh*3,1);
    ini_ = find(F0>seq_(1),1,'first');

    e12a         = muE*0;
    sep12_sector = zeros(Nw,hh*3);
    TFP_sector   = zeros(Nw,hh*3);
    wage_sector  = zeros(Nw,hh*3);    
    e_sectora    = zeros(Nw,hh*3);
    
    TFP_sector(:,1)  = sum(zvec'.*e12a,2);
    wage_sector(:,1) = sum(wvec.*e12a,2);    
    e_sectora(:,1)   = sum(e12a,2);  

    aux    = kron(eye(hh),ones(3,1));
    u      = sum(muU(:));

    for t=2:hh*3        
        ini_           = find(cumsum(Pf(ini_,:))>seq_(t),1,'first');
        Pf_aux         = 0*Pf;
        Pf_aux(:,ini_) = 1;
        Pz_aux         = kron(Pe,Pf_aux);
        v_aux          = 0*vj;
        v_aux(ini_)    = vj(ini_);

        e12a(:,:,t) = (lbdw*RECURSEMAT*e12a(:,:,t-1)*Pz_aux).*(1-sep_) + (fw.*sum((1-lbdw)*RECURSEMAT*e12a(:,:,t-1)*Pz_aux)).*(1-sep_) + qbar*(lbdw_n*fw + (1-lbdw_n)*fw_rigid).*(1-sep_).*repmat(kron(muU*Pe/u,v_aux),Nw,1);  
        
        sep12_sector(:,t) = sum((lbdw*RECURSEMAT*e12a(:,:,t-1)*Pz_aux).*sep_ + (fw.*sum((1-lbdw)*RECURSEMAT*e12a(:,:,t-1)*Pz_aux)).*sep_,2);
        TFP_sector(:,t)   = sum(zvec'.*e12a(:,:,t),2);
        wage_sector(:,t)  = sum(wvec.*e12a(:,:,t),2);
        e_sectora(:,t)    = sum(e12a(:,:,t),2);
    end        

    sep_q  = sep12_sector*aux;
    wage_q = wage_sector*aux;
    tfp_q  = TFP_sector*aux;
    e_qa   = e_sectora*aux;
end