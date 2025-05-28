
clear all
clc;
global nmom np datmom iter_mom
%% DECLARE PARAMS TO ESTIMATE
np=4; %number of parameters
xguess=zeros(np,1);
lb=[0.002, 0.08, 0.08, 0.35]; %lower bound
ub=[0.01, 0.18, 0.18,  0.55]; %Upper bound
x = ((lb+ub)/2)';
save xsol
load xsol
xguess=x;
%% READ DATA MOMENTS -- Cdata %%
%%Load from csv
delimiterIn = ' ';
headerlinesIn = 1;
Cdata = importdata('data_mom.txt',delimiterIn,headerlinesIn);
nmom=size(Cdata.data,2);
datmom=size(nmom,1);
for i_m=1:nmom
 datmom(i_m,1)=Cdata.data(i_m);
end 

minim = 1; %0 dont run estimation
if (minim == 1)
    iter_mom=0;
    
    %Minimization
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    %sol=objective_func(xguess)
    [x,fval] = fmincon(@(x)objective_func(x),xguess,A,b,Aeq,beq,lb,ub);
    %[x,fval] = fminsearch(@(x)objective_func(x),xguess);
    
    save('xsol','x','fval');
end

load xsol

%%% - Run SS again with x, store results
run main_ss




