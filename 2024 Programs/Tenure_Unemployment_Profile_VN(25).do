**Set directory
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"
cd "${mypath}/Data/Clean"

**Build the full file
use year month cpsidp EU12 using fullcps_microreg, clear

gen time= ym(year, month)
format time %tm

*Create variables for unemployment, leaving labor force, and not working (leaving and unemployment combined) 
sort cpsidp time 

gen f12unemployed= F12.EU12

*Merge with 
merge 1:1 year month cpsidp using "/Users/viveknarayan/Downloads/cps_00048.dta"

replace jtyears= ceil(jtyears)


keep if inrange(jtyears, 1, 30)


save fullcps_jtyears, replace

collapse(mean) mean_unemployed= f12unemployed (semean) se_unemployed= f12unemployed [aw=jtsuppwt], by(jtyears)


tsset jtyears
	gen lower_ci = mean_unemployed - invttail(_N-1, 0.025) * se_unemployed 
	gen upper_ci = mean_unemployed + invttail(_N-1, 0.025) * se_unemployed

twoway (rarea lower_ci upper_ci jtyears, color(gs10)) (tsline mean_unemployed, lcolor(blue) lwidth(medium)), ytitle("Separation rate") xtitle("Job tenure") title("12 month separation rate over length of time at current job") legend(order(2 "Separation rate" 1 "95% CI"))

twoway (lowess mean_unemployed jtyears, lcolor(blue) lwidth(medium)), ytitle("Separation rate") xtitle("Job tenure") title("12 month separation rate over length of time at current job") 

graph export "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Data/Clean/Separation Rate by Job Tenure.jpg", replace as(jpg) name("Graph") quality(100)





