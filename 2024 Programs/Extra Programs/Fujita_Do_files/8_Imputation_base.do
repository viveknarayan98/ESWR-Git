*If you don't want to compute the CI, comment out the relevant sections below. 
*It will take a lot longer to run with that section. 

clear

set more off

cd "$dta"

use cps_matched_all_additional_vars.dta


*Set the cyclical indicators here 
**********************************
local Cycl "c.JJrSS1Tr c.JJrSS1Cy"

************************************
local name "JJSS1CycTr"


drop if datem<tm(1995m9) 
 
gen JJm=.
gen B = . 
gen theta=.
gen JJpredNoRIP=.

*** Following variables are needed to compute confidence bands 
gen phi =.
gen ones = 1
gen Jacb1 =.
tabulate hrmis0, generate(hrmis0D)
replace hrmis0D1 = 0 
tabulate pesex, generate(pesexD)
replace pesexD1 = 0
tabulate pemaritl0, generate(pemaritl0D)
replace pemaritl0D1 = 0
tabulate peeduca0, generate(peeduca0D)
replace peeduca0D1 = 0
tabulate age_grp, generate(age_grpD)
replace age_grpD1  =0
************************************************************

foreach x of numlist 1/5{

	regress JJ i.RIPFLAG##(i.month0 i.hrmis0 i.pesex ib4.pemaritl0 ib2.peeduca0 ib2.age_grp i.mjrind0 i.mjrocc0 `Cycl') if SlfPrx==`x' & EEv==1 [pweight=wgt]

	estimates store R`x'
	
	gen RIPSTORE = RIPFLAG 
	replace RIPFLAG=0
	predict JJpred0  if SlfPrx==`x' & EE==1, xb
	*Predicted values of EE based on the pre-2007 estimates as RIPFLAG set to 0. 
	
	replace theta = JJ - JJpred0 if SlfPrx==`x' & EEv==1
	*The bias term only for EEv people
	
	replace RIPFLAG = RIPSTORE
	**Restore the RIPFLAG as before
	
	predict JJpred1 if SlfPrx==`x' & EE==1, xb
	*This is the prediction with the two dummies. 
	
	
	replace B = JJpred1 - JJpred0 if SlfPrx==`x' & EE==1
	*This gives theta (the Dummy parts)
	
      replace JJm  = JJpred0 - (PEEv/(1-PEEv))*B if SlfPrx==`x' & EEm==1	

******* These variables for confidence interval  ***********
   replace phi   = normalden(PEEv_xb) if SlfPrx==`x' & EEm==1
   replace Jacb1  = -1/(1-PEEv)^2*phi*B if SlfPrx==`x' & EEm==1
************************************************************

replace JJpredNoRIP = JJpred0 if SlfPrx==`x'

drop JJpred0 JJpred1 RIPSTORE
}

************* For the calculation of the CI*********************

gen datevar = year0*100 + month0
local x = 200701

while `x'<= 202211{
	di `x'
	foreach y of numlist 1/5{
	*matrix veca W`x'`y' = ones wgt if datevar == `x' & SlfPrx==`y' & EEm==1 & JJm ~= .
	*matrix list W`x'`y'
	*matrix w`x'`y' = W`x'`y'[1,1]
	
	if `x' == 201505{
	matrix veca Jacb`x'`y' = Jacb1 pesexD* pemaritl0D* peeduca0D* age_grpD* if datevar == `x' & SlfPrx== `y' & EEm==1 & JJm ~= . [pweight=wgt]
	}
	*This adjustment is necessary because hrmis0 could not be used for the Probit. See the code for Probit
	else{ 
	matrix veca Jacb`x'`y' = Jacb1 hrmis0D* pesexD* pemaritl0D* peeduca0D* age_grpD* if datevar == `x' & SlfPrx== `y' & EEm==1 & JJm ~= . [pweight=wgt]
	}
	
	
	
	
	
	*matrix Jacb`x'`y' = Jacb2`x'`y'/w`x'`y'[1,1]
	*matrix Jacb`x'`y' = Jacb2`x'`y'
	*Standard errors are for the sum not the average, so I did not need to divide by sum of weights 
	}
	local x = `x' + 1
	if (`x'-13)/100 == int((`x'-13)/100) {
	local x = `x' + 88
	}
}

preserve 
clear 
local x = 200701
while `x'<= 202211{
		foreach y of numlist 1/5{
		svmat Jacb`x'`y'
		save  Jacb`x'`y'.dta, replace
		clear
		}
local x = `x' + 1
if (`x'-13)/100 == int((`x'-13)/100) {
    local x = `x' + 88
}
}
restore 
**************


log using "ImputationResults.smcl", replace

estimates table R1 R2 R3 R4 R5, drop(i.month0 i.mjrind0 i.mjrocc0 i.RIPFLAG#i.month0 i.RIPFLAG#i.mjrind0 i.RIPFLAG#i.mjrocc0) style(columns) star(0.1 0.05 0.01)  b(%9.3f) stats(N r2) 

log close

preserve

keep if EEv==1

collapse (mean) theta B year0 month0 [fweight=wgt], by(datem SlfPrx)
reshape wide theta B, i(datem year0 month0) j(SlfPrx)

export excel using BTwoDummies`name'.xlsx, firstrow(var) replace

restore

gen     JJFn = JJ   if  EEv == 1
replace JJFn = JJm  if  EEm == 1

foreach x of numlist 1/5{
	gen JJFn`x' = JJFn if SlfPrx==`x'
}

save ee_micro_final.dta, replace 

collapse (sum) EU EN EEv EEm JJ JJFn EU1 EN1 EEv1 EEm1 JJ1 JJFn1  EU2 EN2 EEv2 EEm2 JJ2 JJFn2 EU3 EN3 EEv3 EEm3 JJ3 JJFn3 EU4 EN4 EEv4 EEm4 JJ4 JJFn4 EU5 EN5 EEv5 EEm5 JJ5 JJFn5 (mean) JJr* UEr* year0 month0 [fweight=wgt], by(datem)

save E2ETemp.dta, replace 


foreach x of numlist 1/5{
	gen E`x' = EEv`x' + EU`x' + EN`x'+ EEm`x'
	gen JJr`x'_Imp = JJFn`x'/(E`x')
	gen JJr`x'_MAR =  (JJ`x'+JJ`x'*(EEm`x'/EEv`x'))/E`x'
	gen JJr`x'_FF  = JJ`x'/E`x'
}


gen JJr_Imp  =   JJFn/(EU+EN+EEv+EEm)
gen JJr_FF   =   JJ/(EU+EN+EEv+EEm)
gen JJr_MAR  =  (JJ+JJ*(EEm/EEv))/(EU+EN+EEv+EEm)



keep year0 month0 JJr* UEr
order year0 month0 JJr*


export excel using Imp_2Dummies`name'.xlsx, firstrow(var) replace

