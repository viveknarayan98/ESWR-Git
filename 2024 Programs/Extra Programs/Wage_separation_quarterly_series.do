*Set directory*

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"
cd "${mypath}/Data/Clean"

*Load data*
use fullcps, clear

*Set quarterly time*
generate quarter= ceil(month/3)
replace time= yq(year, quarter)
format time %tq

*Collapse wage data*
collapse (mean) mean_wage=wage (p50) median_wage=wage (sd) sd_wage=wage [aw=earnwt], by(time)


save wage_quarterly, replace

*Load data again*
use fullcps, clear


*Denominator*
gen empdenom= 1 if l_status!=. & l.l_status==1

*Separations*
gen EU        = 0 if l_status!=. & L.l_status==1
replace EU    = 1 if EU==0 & l_status==2

*Average weights*
gen averageweight= (wtfinl + l.wtfinl)/2

*Set quarterly time*
generate quarter= ceil(month/3)
replace time= yq(year, quarter)
format time %tq

*Collapse data by quarter*
collapse(sum) EU empdenom [aw=averageweight], by(time)

save separation_quarterly, replace

merge 1:1 time using wage_annual
drop _merge

rename time qdate

save wage_sep_quarterly

merge 1:1 qdate using fred_quarterly_1979q1_2024q4

drop _merge

save macro_quarter_fulldataset, replace

