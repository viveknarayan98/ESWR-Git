global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Data/Clean"

use "${mypath}/Data/Raw/Original CPS Downloads/cps_00039.dta", clear

append using "${mypath}/Data/Raw/Original CPS Downloads/cps_00040.dta"

keep if inrange(age, 25, 55)

keep if inrange(year, 1993, 2004)

drop faminc pernum cpsidv

merge 1:1 year month cpsidp using "${mypath}/Data/Raw/Original CPS Downloads/cps_00044.dta"

keep if _merge==3

drop _merge

merge m:1 ind1990 using ind1990LCxwalk_annual

drop _merge 

save fullcps9304, replace

