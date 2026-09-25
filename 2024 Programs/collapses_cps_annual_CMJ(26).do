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

* Login into folder
cd "${mypath}/Data/Clean"

*Only one of these can equal 1
local most_restrictive = 0
local less_restrictive = 0
local no_restrictions = 0
local baseline = 1

************Collapse wages****************

use wage hours year ind1990 LineCode earnwt l_status using fullcps, clear

*keep if l_status!=3

collapse(mean) wage [aw=earnwt*hours], by(year LineCode)

save collapsedwages_i, replace


***********Collapse hours_i*******************

use hours year ind1990 LineCode earnwt l_status using fullcps, clear

keep hours year ind1990 LineCode earnwt l_status

*keep if l_status!=3

collapse (mean) hours_i = hours [aw=earnwt], by(year LineCode)

save collapsed_hours_i, replace


***********Collapse demographics_i*************

use year month cpsidp LineCode empstat l_status hours lnwage age gradeate nWhite sex unionm unionc educ wtfinl ind1990 mish using fullcps, clear

*keep year month cpsidp LineCode empstat l_status hours lnwage age gradeate nWhite sex unionm unionc educ wtfinl ind1990 mish
*job_stayer job_changer job_changer_unknown

*keep if l_status!=3


preserve

*HS Dropout*
gen educationlevel=1 if educ<72 & educ !=.

*HS Grad*
replace educationlevel= 2 if inrange(educ, 72, 73)

*Some College*
replace educationlevel=3 if inrange(educ, 74, 109)

*College Grad*
replace educationlevel=4 if inrange(educ,110, 111)

*Postgrad*
replace educationlevel=5 if educ>111  & educ !=.

tab educationlevel, gen(education)
drop educationlevel


gen male          = (sex==1)
gen EmploymentCPS = l_status==1

collapse (sum) EmploymentCPS (mean) age gradeate nWhite male unionm unionc education*  [iw=wtfinl], by(year LineCode)

save collapsed_demographics_i, replace

************Collapse separations and wage changes************

restore

*Switch to monthly time

gen time = ym(year, month)

format time %tm

sort cpsidp time

tsset cpsidp time
tsset cpsidp time

*Wage change calculation
gen awchange = s12.lnwage
gen wchange0 = 0 if awchange!=. 
replace wchange0 = 1 if wchange0 == 0 & abs(awchange)<=0.005

gen wchangep = 0 if awchange!=. 
replace wchangep = 1 if wchangep==0 & awchange>0.005

gen wchangen = 0 if awchange!=.
replace wchangen = 1 if wchangen==0 & awchange<-0.005


*Separations calculation
gen EU        = 0 if l_status!=. & L.l_status==1
gen EN 	      = EU
replace EU    = 1 if EU==0 & l_status==2
replace EN    = 1 if EN==0 & l_status==3

*Account for people that have not been observed for 9 months between mish 4 and mish 5
replace EU=1 if mish==5 & L9.l_status==1 & l_status==2

*Employed to employed flows
gen EE=1 if   l_status==1 & l.l_status==1

*Unemployment to employment flows
gen UE        = 0 if l_status!=. & L.l_status==2
gen NE 	      = 0 if l_status!=. & L.l_status==3
replace UE    = 1 if UE==0 & l_status==1
replace NE    = 1 if NE==0 & l_status==1

gen empdenom= 1 if l_status!=. & l.l_status==1

gen averageweight= (wtfinl + l.wtfinl)/2
gen averageweightoneyear= (wtfinl + l12.wtfinl)/2


keep EE EU EN UE NE empdenom wchange0 wchangen wchangep averageweight averageweightoneyear LineCode year 

*Wage changes collapsed
preserve
collapse (sum) wchange0 wchangen wchangep [aw=averageweightoneyear], by(year LineCode)

gen wrigid = wchange0/(wchange0+wchangen)
save "wagechanges_i", replace

*Separations collapsed
restore

collapse(sum) EE EU EN UE NE empdenom [aw=averageweight], by(year LineCode)
save separations_i, replace

*Merging files for macro regression
local files_to_merge collapsedwages_i collapsed_demographics_i wagechanges_i collapsed_hours_i

foreach file in `files_to_merge'{
	merge 1:1 year LineCode using `file'
	drop _merge
}

merge m:1 LineCode using Line_Code_Descrip_Annual
drop _merge

* annual_inflation-gdp has _merge
merge 1:1 year LineCode using annual_inflation_gdp
drop if _merge==2
drop _merge


gen thours = EmploymentCPS*hours_i
gen prodh_i = GDP/thours
gen lprod= log(prodh_i)


*Check what is going on here
rename Inflation_index price_i
gen lprice= log(price_i)

tsset LineCode year
gen prod_growth = d.lprod
gen dlprice = d.lprice


save merged_cps_annual, replace

