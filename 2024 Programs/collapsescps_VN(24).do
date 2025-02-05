global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

cd "${mypath}/Data/Clean"

use w_MINwindow w_MINwhole gradeate age nWhite  wage hours year month LineCode earnwt using fullcps0523mincer, clear


*Collapses wages
generate quarter= ceil(month/3)
gen time= yq(year, quarter)
format time %tq

collapse(mean) w_MINwindow w_MINwhole  wage (p50) w_MINwindow_p50=w_MINwindow w_MINwhole_p50=w_MINwhole [aw=earnwt*hours], by(time  LineCode)

save collapsedwages_i, replace


* Collapses hours
use hours year month LineCode  earnwt using fullcps0523, clear

generate quarter= ceil(month/3)
gen time= yq(year, quarter)
format time %tq
keep hours time LineCode  earnwt

collapse(mean) meanhours=hours [aw=earnwt], by(time  LineCode)

save collapsedhours_i, replace

*Collapses demographics_i

use year month cpsidp  LineCode empstat l_status hours wage age gradeate nWhite sex unionm unionc educ wtfinl using fullcps0523mincer, clear

generate quarter= ceil(month/3)
gen time= yq(year, quarter)
format time %tq


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

save collapsed_demographics_i, replace


use fullcps0523mincer, clear


* Switch to monthly time

gen time = ym(year, month)

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
generate quarter= ceil(month/3)
replace time= yq(year, quarter)
format time %tq

keep EE EU EN UE NE empdenom wchange0 wchangen wchangep  averageweight averageweightoneyear LineCode time 

preserve
collapse(sum) EE EU EN UE NE empdenom [aw=averageweight], by(LineCode time )
save separations, replace
restore


collapse (sum) wchange0 wchangen wchangep [aw=averageweightoneyear], by(LineCode time )
save wagechanges, replace


use employeesgdpmerged, clear

drop if industry_name==""

*rename statecode 

merge 1:1  LineCode time using separations
keep if _merge==3
drop _merge

merge 1:1  LineCode time using collapsedwages_i

keep if _merge==3
drop _merge


merge 1:1  LineCode time using collapsedhours_i
keep if _merge==3

gen rate = EU/empdenom

drop _merge

merge 1:1  LineCode time using collapsed_demographics_i
keep if _merge==3
drop _merge

merge 1:1  LineCode time using wagechanges
keep if _merge==3
drop _merge

gen thours = Employment*meanhours
gen price_i  = NominalGDP/RealGDP
drop NominalGDP 
rename RealGDP GDP


save mergedcollapsedcps, replace

