*Clear directory 

clear all
cls

**Set directory
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Data/Clean"

**Set

*Use 2005-2023 dataset
use fullcps0523mincer, clear
	keep if inrange(age, 25, 55)
	keep w_MINwindow cpsidp year month 

*Use 1993-2004 dataset
append using fullcps9304mincer
	keep if inrange(age, 25, 55)
	keep w_MINwindow cpsidp year month 
		

*Use 1979-1992 dataset
append using fullcps7992mincer
	keep if inrange(age, 25, 55)
	keep w_MINwindow cpsidp year month 
		
*Merge with tenure data
merge 1:1 year month cpsidp using "/Users/viveknarayan/Downloads/cps_00048.dta"
drop _merge

*Generate time and create time series
gen time= ym(year, month)
	sort cpsidp time
	xtset cpsidp time

*Replace job tenure with a rounded number and
replace jtyears= ceil(jtyears)
keep if inrange(jtyears, 1, 30)

save mincer_jtyears, replace

collapse(mean) mean_mincer= w_MINwindow (semean) se_mincer= w_MINwindow [aw=jtsuppwt], by(jtyears)

tsset jtyears
	gen lower_ci = mean_mincer - invttail(_N-1, 0.025) * se_mincer 
	gen upper_ci = mean_mincer + invttail(_N-1, 0.025) * se_mincer

twoway (rarea lower_ci upper_ci jtyears, color(gs10)) (tsline mean_mincer, lcolor(blue) lwidth(medium)), ytitle("Mincer Residual") xtitle("Job tenure") title("Mincer residual over length of time at current job") legend(order(2 "Mincer residual" 1 "95% CI"))
graph export "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Data/Clean/Mincer_graph.jpg", replace as(jpg) name("Graph") quality(100)
