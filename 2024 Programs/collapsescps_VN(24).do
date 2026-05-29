global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"

cd "${mypath}/Data/Clean"

use fullcps, clear
keep if year >=2005

drop LineCode

*Quarterly LineCode
merge m:1 ind1990 using ind1990LCxwalk
keep if _merge==3
drop _merge


*Collapses wages
generate quarter= ceil(month/3)
replace time= yq(year, quarter)
format time %tq

save fullcps0523, replace

collapse(mean)  wage [aw=earnwt*hours], by(time  LineCode)

save collapsedwages_q, replace


* Collapses hours
use hours time LineCode  earnwt using fullcps0523, clear


collapse(mean) meanhours=hours [aw=earnwt], by(time  LineCode)

save collapsedhours_q, replace

*Collapses demographics_i

use time cpsidp  LineCode empstat l_status hours wage age gradeate nWhite sex unionm unionc educ wtfinl using fullcps0523, clear



*HS Dropout*
gen educationlevel=1 if educ<72

*HS Grad*
replace educationlevel= 2 if inrange(educ, 72, 73)

*Some College*
replace educationlevel=3 if inrange(educ, 74, 109)

*College Grad*
replace educationlevel=4 if inrange(educ,110, 111)

*Postgrad*
replace educationlevel=5 if educ>111

tab educationlevel, gen(education)
drop educationlevel


gen male          = (sex==1)
gen EmploymentCPS = l_status==1

collapse (sum) EmploymentCPS (mean) age gradeate nWhite male unionm unionc education* if EmploymentCPS==1 [iw=wtfinl], by(time  LineCode)

save collapsed_demographics_q, replace


use fullcps0523, clear


* Switch to monthly time

replace time = ym(year, month)

format time %tm

sort cpsidp time

tsset cpsidp time
tsset cpsidp time

gen awchange = s12.lnwage
gen wchange0 = 0 if awchange!=.
replace wchange0 = 1 if wchange0 == 0 & abs(awchange)<=0.005

gen wchangep = 0 if awchange!=.
replace wchangep = 1 if wchangep==0 & awchange>0.005

gen wchangen = 0 if awchange!=.
replace wchangen = 1 if wchangen==0 & awchange<-0.005


gen EU        = 0 if l_status!=. & L.l_status==1
gen EN 	      = EU
replace EU    = 1 if EU==0 & l_status==2
replace EN    = 1 if EN==0 & l_status==3

gen EE=1 if   l_status==1 & l.l_status==1

gen UE        = 0 if l_status!=. & L.l_status==2
gen NE 	      = 0 if l_status!=. & L.l_status==3
replace UE    = 1 if UE==0 & l_status==1
replace NE    = 1 if NE==0 & l_status==1

gen empdenom= 1 if l_status!=. & l.l_status==1

gen averageweight= (wtfinl + l.wtfinl)/2
gen averageweightoneyear= (wtfinl + l12.wtfinl)/2


*Quarterly time for collapsing
replace time= yq(year, quarter)
format time %tq

keep EE EU EN UE NE empdenom wchange0 wchangen wchangep  averageweight averageweightoneyear LineCode time 

preserve
collapse(sum) EE EU EN UE NE empdenom [aw=averageweight], by(LineCode time )
save separations_q, replace
restore


collapse (sum) wchange0 wchangen wchangep [aw=averageweightoneyear], by(LineCode time )
save wagechanges_q, replace


use employeesgdpmerged, clear

drop if industry_name==""
drop if LineCode==.

*rename statecode 

merge 1:1  LineCode time using separations_q
keep if _merge==3
drop _merge

merge 1:1  LineCode time using collapsedwages_q

keep if _merge==3
drop _merge


merge 1:1  LineCode time using collapsedhours_q
keep if _merge==3

gen rate = EU/empdenom

drop _merge

merge 1:1  LineCode time using collapsed_demographics_q
keep if _merge==3
drop _merge

merge 1:1  LineCode time using wagechanges_q
keep if _merge==3
drop _merge

gen thours = Employment*meanhours
gen price_i  = NominalGDP/RealGDP
gen wrigid = wchange0/(wchange0 + wchangen)
drop NominalGDP 
rename RealGDP GDP
gen prodh_i = GDP/thours 
gen lprod= log(prodh_i)
gen lprice= log(price_i)

save merged_cps_quarterly, replace

