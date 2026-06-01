******
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Programs/ESWR-Git/Data/Clean"



use fullcps, clear

fmerge 1:1 year month cpsidp using "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git/Data/Raw/Original CPS Downloads/cps_00057.dta", keepusing(hrhhid hrhhid2 lineno) nogen

keep if year>1995

gen datem= ym(year, month)
format datem %tm

fmerge 1:1 datem hrhhid hrhhid2 lineno using "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git/Data/Clean/ee_micro_cut.dta", keepusing(JJFn) nogen


drop if year==.
drop if year==2023

gen job_stayer = 1 if JJFn==0

gen job_stayer_mish_8=.

replace job_stayer_mish_8=1 if L.job_stayer==1 & L2.job_stayer==1 & L3.job_stayer==1 & mish==8

gen awchange = s12.lnwage
gen wchange0 = 0 if awchange!=. 
replace wchange0 = 1 if wchange0 == 0 & abs(awchange)<=0.005

gen wchangep = 0 if awchange!=. 
replace wchangep = 1 if wchangep==0 & awchange>0.005

gen wchangen = 0 if awchange!=.
replace wchangen = 1 if wchangen==0 & awchange<-0.005

gen averageweightoneyear= (wtfinl + l12.wtfinl)/2 

collapse (sum) wchangen wchange0 [aw=averageweightoneyear], by(year)

gen wrigid = wchange0/(wchangen + wchange0)

tsset year

tsline wrigid

