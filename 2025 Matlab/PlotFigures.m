%% ------------------------------------------------------------------------
% PlotFigures.m: Plots figures 
% -------------------------------------------------------------------------
% Wage Rigidity, Endogenous Separations, and Labor productivity
% Joaquin Garcia-Cabo, Camilo Morales-Jimenez, Vivek Naranyan
% -------------------------------------------------------------------------
% This version: Spring 2025
% -------------------------------------------------------------------------

figure('name','wage growth')
plot(1:length(wage_growth),wage_growth)
xlabel('horizon')
ylabel('Wage growth')
title('Wage growth for the Continuously Employed')

figure('name','Fraction of wage changes')
plot(1:length(w0_change),w0_change./E_level)
hold on,plot(1:length(w0_change),lbdw.^(1:12))
xlabel('horizon')
ylabel('Fraction')
legend('observed','calvo^h')
title('fraction of 0 wage changes')

figure('name','Sep by wage')
plot(log(wvec),sep12_w*100,'*')
hold on
plot(log(wvec),sep12_wfit*100,'-')
title('Probability of unemployment in 12 periods')
xlabel('log wage')
ylabel('separation')
yyaxis right
plot(log(wvec),sum(muE,2))
ylabel('distribution')
legend('Conditional on wage','fit','distribution')


% figure('name','Unconditional E and U 12 periods')
% subplot(1,2,1), plot(0:size(E_h,3)-1,squeeze(sum(sum(E_h,1),2))/sum(muE(:)));
% title('Prob of employment at h')
% xlabel('h')
% subplot(1,2,2), plot(0:size(E_h,3)-1,squeeze(sum(sum(U_h,1),2))/sum(muE(:)));
% title('Prob of unemployment at h')
% xlabel('h')

figure('name','Sep by wage and tenure')
subplot(1,2,1), plot(log(wvec),sep_by_w), title('separation by wage')
xlabel('log(wage)')
ylabel('separation probability')
yyaxis right
plot(log(wvec),sum(muE,2))
ylabel('distribution')

subplot(1,2,2), plot(sep_by_tenure), title('separation by tenure')
xlabel('tenure')
ylabel('separation probability')

figure('name','J and W')
subplot(1,2,1), plot(Jcont), title('Jcont')
subplot(1,2,2), plot(Wcont), title('Wcont')

figure('name','Separation DR')
plot(sep_), title('Separations')

figure('name','Productivity distribution')
plot(log(evecx),muU/sum(muU(:)))
hold on
plot(log(evecx),sum(muE*kron(eye(Ne),ones(Nf,1)))/sum(muE(:)))
plot(log(evecx),p0e)
legend('unemployed','employed','unconditional')
xlabel('log(ze)')
title('Productivity distribution')

figure('name','Mincer plot')
plot(log(wvec)-mlwage,cumsum(Edist_)/sum(Edist_))
hold on
plot(distri_data(1:end-1),0.1:0.1:0.9,'*-')
xlim([distri_data(1)-0.1 distri_data(end-2)+0.1])
grid on
xlabel('Mincer residual')
ylabel('PDF')
title('Mincer plot')


