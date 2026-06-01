

*Set Directory
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

cd "${mypath}/Data/Raw/Original CPS Downloads"

*2010 onwards data
use cps_00041, clear

*2000 onwards data
append using cps_00040

keep if inrange(year, 2001, 2023)

*Helps to make everything smaller

drop asecflag pernum cpsidv asecflag hwtfinl serial faminc

keep if inrange(age, 15, 64)

sort cpsidp year month

gen time = ym(year, month)

format time %tm

xtset cpsidp time
xtset cpsidp time

*-----------------------------------------------------------------------	
* generate labor force status
*-----------------------------------------------------------------------
	gen l_status = .
	replace l_status = 1 if empstat == 10 | empstat == 12
	replace l_status = 2 if empstat >= 20 & empstat <= 22 & empstat !=.
	replace l_status = 3 if empstat >= 30 & empstat !=.
	
*Create separations

gen EU        = 0 if l_status!=. & L.l_status==1
replace EU    = 1 if EU==0 & l_status==2

*Keeps only private sector jobs
keep if ind1990<900

gen employed=1 if l_status==1


*Collapsing employed and unemployed by time vars
collapse(sum) EU employed [iw=wtfinl], by(year month)

*Load directory
cd "${mypath}/Data/Clean"

*Save Separations CPS
save cps_separations_0124, replace

use LD_JOLTS, clear

keep if industrycode==9

merge 1:1 year month using cps_separations_0124

tsset time 

gen CPS_seprate= (EU/employed)*100

label variable CPS_seprate "CPS"
label variable LD "JOLTS"

drop if year==2001 & month==1

tsline CPS_seprate LD, xtitle("Time") ytitle("Separation Rate")

save CPS_JOLTS
