*Set Directory
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

cd "${mypath}/Data/Raw/Original CPS Downloads"


*2010 onwards data
use cps_00041, clear

*2000 onwards data
append using cps_00040

keep if inrange(year, 2005, 2023)

*Helps to make everything smaller

drop asecflag pernum cpsidv asecflag hwtfinl serial faminc

drop if ind1990==0

keep if inrange(age, 25, 55)

*Adding missing vars
cd "${mypath}/Data/Raw/Original CPS Downloads"

merge 1:1 year month cpsidp using cps_00047

keep if _merge==3

drop _merge

cd "${mypath}/Data/Clean"

*Merge with industry crosswalk

merge m:1 ind1990 using ind1990LCxwalk

keep if _merge==3 

drop _merge

sort cpsidp year month

save fullcps0523, replace
