clear;
addpath('/if/research-afe/joaquin/nlopt_test');
opt.algorithm = NLOPT_LD_MMA
opt.lower_bounds = [-inf, 0]
opt.min_objective = @myfunc_b
opt.fc = { (@(x) myconstraint(x,2,0)), (@(x) myconstraint(x,-1,1)) }
opt.fc_tol = [1e-8, 1e-8];
opt.xtol_rel = 1e-4

[xopt, fmin, retcode] = nlopt_optimize(opt, [1.234 5.678])

% Display results
fprintf('Optimal x: [%f, %f]\n', xopt(1), xopt(2));
fprintf('Minimum value: %f\n', fmin);
fprintf('Return code: %d\n', retcode);
