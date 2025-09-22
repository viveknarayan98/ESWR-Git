function piz = ergodicpi(Pz)

Nz  = size(Pz,1);
piz = ones(Nz,1)/Nz; % random guess to start with productivity CDF

errz = 8; itz = 1;

%ergodic distribution of z
while max(errz) > 1e-8
    PP = Pz; mm = piz';    
    mm_np = mm*PP;
    errz  = max(abs(mm_np-mm));
    piz   = mm_np';    
    itz = itz+1;
end
return