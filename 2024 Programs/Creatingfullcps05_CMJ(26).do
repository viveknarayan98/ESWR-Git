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
cd "${mypath}/Data/Raw/Original CPS Downloads"

* Combine files
append using cps_00050 cps_00040

* Earnweek changed name
replace earnweek = earnweek2 if (year==2023 & month>=4) | year>2023

* Selection
keep if inrange(year, 2005, 2023)
*drop if ind1990==0
keep if inrange(age, 25, 55)

*Adding missing vars
merge 1:1 year month cpsidp using cps_00047
drop asecflag pernum cpsidv asecflag hwtfinl serial faminc
drop if _merge==2
drop _merge


*Merge with industry crosswalk
merge m:1 ind1990 using "${mypath}/Data/Clean/ind1990LCxwalk"
drop if _merge==2
drop _merge

* Sort and save
cd "${mypath}/Data/Clean"
sort cpsidp year month
save fullcps0523, replace
