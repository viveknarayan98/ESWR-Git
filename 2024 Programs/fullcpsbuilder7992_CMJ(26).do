***This file will build a full cps for 79-92
clear 
cls 

* Declare user
global user = "c"

* Global folder
if "$user"=="v" {
	global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"
}
if "$user"=="c" {
	global mypath "/mq/scratch/m1cxm05/ESWR"
}

cd "${mypath}/Data/Clean"

use "${mypath}/Data/Raw/Original CPS Downloads/cps_00038.dta", clear

*Pre 1982 is taken care of by MORG Earnings
keep if year>= 1982

*Appending 1979-1981 microdata

append using 79morgearnings 8081morgearnings "${mypath}/Data/Raw/Original CPS Downloads/cps_00039.dta"

*Managing file size
keep if year <= 1992

merge 1:1 year month cpsidp using "${mypath}/Data/Raw/Original CPS Downloads/cps_00044.dta" 
drop if _merge==2

keep if year <=1992
drop _merge faminc asecflag cpsidv pernum hwtfinl serial

merge m:1 ind1990 using ind1990LCxwalk
drop if _merge==2

drop _merge 

keep if inrange(age, 25, 55)

save fullcps7992, replace

