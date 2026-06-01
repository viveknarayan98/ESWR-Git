global mypath "/Users/viveknarayan/Documents/vivek_camilo_project Rob Chen"

cd "${mypath}/Data/Clean"

* Declare panel
use year month cpsidp LineCode l_status mish empsame lnwage using fullcpsdata, clear
gen time = ym(year, month)
format time %tm
sort cpsidp time
tsset cpsidp time
tsset cpsidp time

* Annual job changers
gen employerchange=1 if empsame==1
replace employerchange=0 if empsame==2

gen jobchange = 0 if l_status ==1 & L.l_status==1
replace jobchange = 1 if l_status ==1 & L.l_status==1 & employerchange==1

gen jobchange12_lc = 0 if l_status ==1 & L12.l_status==1 & L1.l_status==1 & L2.l_status==1  & L3.l_status==1
replace jobchange12_lc = 1 if jobchange12_lc==0 & (L3.LineCode!=L12.LineCode | L2.LineCode!=L3.LineCode | L.LineCode!=L2.LineCode | LineCode!=L.LineCode)

gen jobchange12_lc_alt = 0 if l_status ==1 & L12.l_status==1 & L1.l_status==1 & L2.l_status==1  & L3.l_status==1
replace jobchange12_lc_alt = 1 if jobchange12_lc_alt==0 & (L3.LineCode!=L12.LineCode | L2.jobchange==1 | L.jobchange==1 | jobchange==1)

gen nojob12 = 0 if l_status==1 & L12.l_status==1
replace nojob12 = 1 if nojob12==0 & ((L.l_status!=1 & L.l_status!=.) | (L2.l_status!=1 & L2.l_status!=.) | (L3.l_status!=1 & L3.l_status!=.))

gen jobchange12_se = 0 if l_status ==1 & L12.l_status==1 & L1.l_status==1 & L2.l_status==1  & L3.l_status==1
replace jobchange12_se = 1 if jobchange12_se == 0 & (L2.jobchange==1 | L.jobchange==1 | jobchange==1) 

gen EU12 = 0 if L12.l_status==1 & l_status!=.
replace EU12 = 1 if EU12==0 & (l_status==2 | L.l_status==2 | L2.l_status==2 | L3.l_status==2)  & (l_status!=3 & L.l_status!=3 & L2.l_status!=3 & L3.l_status!=3)

gen EN12 = 0 if L12.l_status==1 & l_status!=.
replace EN12 = 1 if EN12==0 & (l_status==3 | L.l_status==3 | L2.l_status==3 | L3.l_status==3)  & (l_status!=2 & L.l_status!=2 & L2.l_status!=2 & L3.l_status!=2)

gen ENE12 = 0 if L12.l_status==1 & l_status!=.
replace ENE12 = 1 if ENE12==0 & (l_status==2 | L.l_status==2 | L2.l_status==2 | L3.l_status==2 | l_status==3 | L.l_status==3 | L2.l_status==3 | L3.l_status==3) 

gen awchange = s12.lnwage
gen wchange0 = 0 if awchange!=.
replace wchange0 = 1 if wchange0 == 0 & abs(awchange)<=0.005

gen wchangep = 0 if awchange!=.
replace wchangep = 1 if wchangep==0 & awchange>0.005

gen wchangen = 0 if awchange!=.
replace wchangen = 1 if wchangen==0 & awchange<-0.005

save transitions, replace

keep if mish==4 | mish==8
sort cpsidp year month
duplicates drop cpsidp year month, force
saveold transition_mish, v(11.2) replace

use if mish==4 | mish== 8 using fullcpsdata, clear
merge 1:1 cpsidp year month using transition_mish
keep if _merge==3
drop _merge
saveold transition_mish, v(11.2) replace

tsset cpsidp time
gen outcome = .
replace outcome = 1 if EU12 == 1
replace outcome = 2 if EN12 == 1
replace outcome = 3 if outcome==. & ENE12 == 1
replace outcome = 4 if jobchange12_lc == 1
replace outcome = 5 if outcome==. & L12.l_status==1 & l_status==1 & wchange0 ==1
replace outcome = 6 if outcome==. & L12.l_status==1 & l_status==1 & wchangep ==1
replace outcome = 7 if outcome==. & L12.l_status==1 & l_status==1 & wchangen ==1

* Make sure everyone is in one category
sum awchange if outcome==. & l_status==1 & L12.l_status==1
saveold transition_mish, v(11.2) replace

