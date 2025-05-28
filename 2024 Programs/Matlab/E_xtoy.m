%EU = E[max{x+e^x,y+e^y}], with e~Gumbel
function Exy = E_xtoy(x,y,rhoxy)

corr = max( (x/rhoxy) , (y/rhoxy));

Exy   = rhoxy*log( exp((x/rhoxy)-corr) + exp((y/rhoxy)-corr) ) + rhoxy*corr;

return