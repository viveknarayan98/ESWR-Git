    %Check policies: plot nF, eF
    figure(102)
    iwindex = 1;
    k=1;
    for izindex = 1:(20):Nz
        iSindex0 = iwindex + (izindex-1)*Nw;
        iSindex1 = (iwindex + (izindex)*Nw)-1;
        plot (1:Nw,nF(iSindex0:iSindex1,1),'LineWidth',2.25); hold on
        legendinfo{k}=['z =', num2str(izindex)];
        k=k+1;
    end
    legend(legendinfo)
    title('Quit decision active','Interpreter','LaTex','Fontsize',18)
    xlabel('wage grid','Interpreter','LaTex','Fontsize',14)
    legend boxoff
    hold off

    figure(102)
    iwindex = 1;
    k=1;
    for izindex = 1:(20):Nz
        iSindex0 = iwindex + (izindex-1)*Nw;
        iSindex1 = (iwindex + (izindex)*Nw)-1;
        plot (1:Nw,eF(iSindex0:iSindex1,1),'LineWidth',2.25); hold on
        legendinfo{k}=['z =', num2str(izindex)];
        k=k+1;
    end
    legend(legendinfo)
    title('Firing decision','Interpreter','LaTex','Fontsize',18)
    xlabel('wage grid','Interpreter','LaTex','Fontsize',14)
    legend boxoff
    hold off