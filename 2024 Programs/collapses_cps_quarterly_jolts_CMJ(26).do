*Collapses CPS for JOLTS*

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
cd "${mypath}/Data/Clean"

use fullcps0523, clear

*This is putting management and admin+waste services + professional scientific etc into professional business services. This aggregation is based on the supersector definition: https://www.bls.gov/iag/tgs/iag60.htm

*replace trimdescrip = "Prof" if inrange(LineCode, 64, 65)
replace LineCode= 60 if inrange(LineCode, 64, 65)

*This is combining transportation, warehousing, and utilities
*replace trimdescrip = "Tran" if LineCode==10
replace LineCode= 36 if LineCode==10

preserve 

collapse(mean)  wage [aw=earnwt*hours], by(time  LineCode)

save collapsedwages_q_jolts, replace


* Collapses hours
restore, preserve


collapse(mean) meanhours=hours [aw=earnwt], by(time  LineCode)

save collapsedhours_q_jolts, replace

*Collapses demographics_i
restore, preserve

keep time cpsidp  LineCode empstat l_status hours wage age gradeate nWhite sex unionm unionc educ wtfinl 



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

save collapsed_demographics_q_jolts, replace


restore


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
save separations_q_jolts, replace
restore


collapse (sum) wchange0 wchangen wchangep [aw=averageweightoneyear], by(LineCode time )
save wagechanges_q_jolts, replace


use integratedstategdp_jolts, clear

*drop if industry_name==""
drop if LineCode==.

*rename statecode 

merge 1:1  LineCode time using separations_q_jolts
keep if _merge==3
drop _merge

merge 1:1  LineCode time using collapsedwages_q_jolts

keep if _merge==3
drop _merge


merge 1:1  LineCode time using collapsedhours_q_jolts
keep if _merge==3

gen rate = EU/empdenom

drop _merge

merge 1:1  LineCode time using collapsed_demographics_q_jolts
keep if _merge==3
drop _merge

merge 1:1  LineCode time using wagechanges_q_jolts
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

save merged_cps_quarterly_jolts, replace

