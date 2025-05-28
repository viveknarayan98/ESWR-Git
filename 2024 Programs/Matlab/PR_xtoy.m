%pr = Pr[x+e^x>=y+e^y], with e~Gumbel
function pr = PR_xtoy(x,y,rhoxy)

corr = max( (x/rhoxy) , (y/rhoxy));

num = exp((x/rhoxy)-corr);
den = exp((x/rhoxy)-corr) + exp((y/rhoxy)-corr);

pr = num./den; 

return