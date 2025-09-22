%% ------------------------------------------------------------------------
% PrintStats.m: Prints table with statistics
% -------------------------------------------------------------------------
% Wage Rigidity, Endogenous Separations, and Labor productivity
% Joaquin Garcia-Cabo, Camilo Morales-Jimenez, Vivek Naranyan
% -------------------------------------------------------------------------
% This version: Spring 2025
% -------------------------------------------------------------------------

% Table 
variable1 = {'Unemployment rate' 
             'Total separation rate'
             'Quit rate'
             'Fire rate'
             'Efficient separation rate' 
             'Exogenous separations'
             'Micro reg (linear)'
             'Micro reg(logit)'
             'Check_separations' 
             'Replacement rate'             
             'Macro sep reg wage'
             'Macro sep reg tfp'
             'Macro prod reg wage '
             'Macro prod reg sep '};
variable2 = [round([unemployment, sep_rate, quit_rate, end_sep_rate, dsep_rate, exo_sep_rate]*100,2),beta_linear(2),beta_logit(2),check_sep, replacement_wage, beta_macro_sep(end-1), beta_macro_sep(end),beta_macro_prod(end-1),beta_macro_prod(end)]; 

 
% Create the table 
myTable = table(variable1, variable2');

% Display the table with title 
disp('My Data Table'); 
disp(myTable); 

% Wage stats
fprintf('\n\n ------------------------------------------------------------------------------------------------------------------')
fprintf('\n log(Wage) distribution in steady state')
fprintf('\n ------------------------------------------------------------------------------------------------------------------ ')
fprintf(['\n Percentile       ',num2str([10 20 30 40 50 60 70 80 90],3),'        Std'])
fprintf('\n             ------------------------------------------------------------------------------------------------------ ')
fprintf(['\n Model          ',num2str(lwj_distri(:,1)',3)])
fprintf(['\n Data           ',num2str(distri_data',3)])
fprintf('\n ------------------------------------------------------------------------------------------------------------------\n ')
        