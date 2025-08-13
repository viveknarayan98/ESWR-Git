8_5_25.mat : contains the parameter solution (xopt) for the "low" unemployment scenario, and while not missing on the regressions, they are less significant. In this version, there are twelve parameters to be estimated, and lbdw and lbdw_n are fixed to the values in LoadParams.m


8_6_25_local.mat: contains the parameter solution for the "high" unemployment scenario, while better matching the regressions. In this version, there are twelve parameters to be estimated, and lbdw and lbdw_n are fixed to the values in LoadParams.m


8_7_25_local.mat: is a very similar parameter solution to a local optimization, as in 8_6_25_local, but lbdw is also estimated, hence xopt is 13x1 and lbdw is 0.9129 (very close to the fixed value of 11/12 or 0.917)


8_8_25_global.mat: is the solution  of a global optimization with the 13 parameters (lbdw included). Interestingly, lbdw here is 0.75 (much lower) but the solution is closer to the "low" unemployment scenario, with a twist: Urate is 5.68%, and the macro regressions are decent (0.78 and -0.33 respectively) but the micro regression is basically 0.