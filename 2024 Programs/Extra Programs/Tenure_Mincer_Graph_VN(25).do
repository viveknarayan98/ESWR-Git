*Clear directory 

/*
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
	

	summarize w_MINwindow, detail
	local p1  = r(p1) 
	local p99 = r(p99)
	
	histogram w_MINwindow if w_MINwindow>=`p1' & w_MINwindow<=`p99', bin(10)
	
	centile w_MINwindow, centile(10(10)90)
	
		
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
*/

use mincer_jtyears, clear

collapse(mean) mean_mincer= w_MINwhole (semean) se_mincer= w_MINwhole [aw=jtsuppwt], by(jtyears)

/*
tsset jtyears
	gen lower_ci = mean_mincer - invttail(_N-1, 0.025) * se_mincer 
	gen upper_ci = mean_mincer + invttail(_N-1, 0.025) * se_mincer

lowess mean_mincer jtyears, generate(yhat)

regress mean_mincer jtyears 
predict yhat, xb
predict se, stdp

gen upper = yhat + 1.96 * se
gen lower = yhat - 1.96 * se
*/


twoway ///
    (scatter mean_mincer jtyears, ///
        mcolor(gs12) msymbol(circle) ///
        legend(off)) ///
    (lowess mean_mincer jtyears, ///
        lcolor(blue) lwidth(medium)), ///
    xtitle("Job tenure (years)") ///
    ytitle("Mincer residual") 

	*title("Mincer Residual over Job Tenure")


	
graph export "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Data/Clean/Mincer_graph.jpg", replace as(jpg) name("Graph") quality(100)
