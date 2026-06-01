clear
set more off

capture log close

cd "$dta"



capture graph drop _all

use cps_matched_all_additional_vars.dta
capture drop UEr* JJr*



**UEr time series
preserve

collapse (sum) UE* UU* UN* (mean) month0 year0 [fweight=wgt], by(datem)
foreach x of numlist 1/5 {
gen  UEr`x'  = UE`x'/(UE`x'+UU`x'+UN`x')
}
gen UEr = UE/(UE+UU+UN)

*Create trend and cyclical components 
tsset datem

drop if datem<tm(1995m9)

gen tr = datem - tm(1995m9)+1

regress UEr c.tr##c.tr 
predict UErTrQuad, xb
predict UErCycQuad, residuals
tsline  UErCycQuad UErTrQuad, name(UErQuad) cmissing(n n n) 

saveold UErtest.dta, version(12) replace

foreach x of numlist 1/5{
	tsfilter hp UErCycHP`x' = UEr`x', trend(UErTrHP`x')  smooth(100000)
	tsline UErCycHP`x' UErTrHP`x' , name(UErHP`x') cmissing(n n n) 
	regress UEr`x' c.tr##c.tr 
	predict UErTrQuad`x', xb
	predict UErCycQuad`x', residuals
	tsline  UErCycQuad`x' UErTrQuad`x' , name(UErQuad`x') cmissing(n n n) 
}

keep datem UEr* 

save UEr.dta, replace
restore

**************
*JJrSS time series 
*************

preserve 

drop if datem<tm(1995m9) 
drop if SlfPrx>1

collapse (sum) EU EN EEv EEm JJ  (mean) year0 month0 [fweight=wgt], by(datem)
gen JJrSS = JJ/(EU+EN+EEv)

keep datem year0 month0 JJrSS

tsset datem 

gen tr = datem - tm(1995m9)+1

regress JJrSS c.tr##c.tr
predict JJrSSTr, xb
predict JJrSSCy, residuals

tsline  JJrSSCy JJrSSTr, cmissing(n n n) name(JJSS)

save JJrSS, replace 
restore 

drop if datem<tm(1995m9) 
drop if SlfPrx>1
drop if hrmis0>1

collapse (sum) EU EN EEv EEm JJ  (mean) year0 month0 [fweight=wgt], by(datem)
gen JJrSS1 = JJ/(EU+EN+EEv)

replace JJrSS1 = (JJrSS1[_n-12]+JJrSS1[_n+12])/2 if datem==tm(2015m5)  
*Note that in 2015m5, all of hrmis0=1 is missing, so JJrSS1 = 0 in this month. We are 
*imputing this value by taking the average. Note that this series is relevant only as 
*a cyclical indicator in the actul imputation procedure.

keep datem year0 month0 JJrSS1

tsset datem 

gen tr = datem - tm(1995m9)+1

regress JJrSS1 c.tr##c.tr
predict JJrSS1Tr, xb
predict JJrSS1Cy, residuals

tsline  JJrSS1Cy JJrSS1Tr, cmissing(n n n) name(JJSS1)

save JJrSS1, replace 

clear 

use cps_matched_all_additional_vars.dta

capture drop _merge
merge m:1 datem using UEr.dta
drop _merge
merge m:1 datem using JJrSS.dta
drop _merge
merge m:1 datem using JJrSS1.dta
drop _merge

save cps_matched_all_additional_vars.dta, replace
