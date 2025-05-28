1. run_program.m : runs the estimation and/or stored parameter solution to obtain policy functions. When running the estimation, it calls objective_func.m.
2. objective_func.m: minimizes the distance between data and model moments. To obtain model moments, runs main_ss.m.
3. main_ss.m : main value function iteration program, sets up params using ext_params, the defined internal ones, and calls V_iter_v3. After finding an equilibrium, saves model moments using mod_moments.m

Additional files
4. Mod_moments.m
5. ext_params.m
6. xsol.mat
7. E_xtoy and Pr_xtoy.m : used to compute value and probabilities with Gumbel shocks.
8. data_mom.txt :data moments to match
