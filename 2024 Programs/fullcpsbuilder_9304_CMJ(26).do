* Housekeeping
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

* Login to folder
cd "${mypath}/Data/Clean"

* Merge data
append using "${mypath}/Data/Raw/Original CPS Downloads/cps_00039.dta" "${mypath}/Data/Raw/Original CPS Downloads/cps_00040.dta"

* Sample selection
keep if inrange(age, 25, 55)
keep if inrange(year, 1993, 2004)
drop faminc pernum cpsidv

* Add other variables
merge 1:1 year month cpsidp using "${mypath}/Data/Raw/Original CPS Downloads/cps_00044.dta"
drop if _merge==2
drop _merge

* Industry data
merge m:1 ind1990 using "${mypath}/Data/Clean/ind1990LCxwalk"
drop if _merge==2
drop _merge 

save fullcps9304, replace

