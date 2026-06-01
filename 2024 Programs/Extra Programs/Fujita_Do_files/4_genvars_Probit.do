clear
set more off

cd "$dta"

local x = 199401
*x is for the starting month

while `x'<=202211{
di `x'
if `x' != 197712 & `x' != 198506 & `x' != 198509 & `x' != 199312 & `x' != 199505 & `x' != 199506 & `x' != 199507 & `x' != 199508{
use  matched`x'.dta

capture drop datem wgt lf0 lf1 EU EN EEv EEm EE JJ ResId0 ResId1 HHResId0 HHResId1 SlfPrx startdate PEEv age_grp PEEv_xb 

gen datem = ym(year0,month0)
format datem %tm

gen wgt = round(fweight0)
drop if (hrmis0==4 | hrmis0==8 | hrmis1==1 | hrmis1==5)
drop if peage<16
drop if pemlr1==. | pemlr1==-1
drop if pemlr0==. | pemlr0==-1

* Recode for E, U, and N
recode pemlr0	(1/2=1) (3/4=2) (5/7=3), gen(lf0)
recode pemlr1	(1/2=1) (3/4=2) (5/7=3), gen(lf1)

gen EU  = (lf0==1 & lf1==2)
gen EN  = (lf0==1 & lf1==3)
gen EEv = (lf0==1 & lf1==1 & puiodp11>0)
gen EEm = (lf0==1 & lf1==1 & puiodp11<0)

*if you tab puiodp1, you see there are -1, -2, and -3 as invalid data (no missing and no zeros either)

gen EE = (lf0==1 & lf1==1)
gen JJ =  (lf0==1 & lf1==1 & puiodp11==2)

** Create variables for self-proxy status
gen ResId0 = pulineno*(puslfprx0==1)
gen ResId1 = pulineno*(puslfprx1==1) 

sort hrhhid hrhhid2 year0 month0
bys hrhhid hrhhid2 year0 month0: egen HHResId0 = sum(ResId0)

sort hrhhid hrhhid2 year1 month1
bys hrhhid hrhhid2 year1 month1: egen HHResId1 = sum(ResId1)

*******************
*assert HHResId0!=0 
*assert HHResId1!=0
*The above assertions are false (around 0.2% of obs have 0s). So there are a small number of "ghosts" responding to the survey.
*I checked whether those ghosts are children (15 or younger) but they are not the ghosts. 
*The thing is that some have puslfprx =-1 or missing. So this is causing the problem but don't know why these people have -1 or ..
*tab HHResId0
*tab HHResId1
*This will show roughly 2% of the househos have zeros for HHResId

drop if HHResId0==0 | HHResId1==0
*I drop these households. 

gen SlfPrx =.
replace SlfPrx = 1 if (pulineno==HHResId0) & (pulineno==HHResId1)
replace SlfPrx = 2 if (pulineno==HHResId0) & (pulineno!=HHResId1)
replace SlfPrx = 3 if (pulineno!=HHResId0) & (pulineno==HHResId1)
replace SlfPrx = 4 if (pulineno!=HHResId0) & (pulineno!=HHResId1) & (HHResId0==HHResId1)
replace SlfPrx = 5 if (pulineno!=HHResId0) & (pulineno!=HHResId1) & (HHResId0!=HHResId1)
*1: self-self 
*2: self-prox
*3: prox-self
*4: prox-prox-same
*5: prox-prox-diff

*Create the timing of the survey start month 
gen startdate = . 
foreach y of numlist 1/8{
bys hrhhid hrhhid2 pulineno: replace startdate = datem-(`y'-1) if hrmis0==`y' & hrmis0<=4 
bys hrhhid hrhhid2 pulineno: replace startdate = datem-(`y'+7) if hrmis0==`y' & hrmis0>=5 
}

format startdate %tm
sort hrhhid hrhhid2 pulineno startdate datem

*Run Probit 
gen PEEv = . 
gen PEEv_xb = . 

recode peage (16/20=1) (21/30=2) (31/40=3) (41/50=4) (51/60=5) (61/70=6) (71/120=7), gen(age_grp)

if `x' <=200612{
	replace PEEv=0
}
else {
	foreach y of numlist 1/5{
	
if `x' == 201505{
	probit EEv i.pesex i.pemaritl0 i.peeduca0 i.age_grp if hrmis0~=1 & SlfPrx==`y' & (lf0==1 & lf1==1) [pweight=wgt]
}
*Note that 201505 matched data have missing values (EEm) for all hrmis0==1. Thus I drop hrmis0 from the regression.
*Note also that hrmis0==1 needs to be excluded from the estimation (The average missing probability will be high because all of hrmis0==1 is EEm). 
else{ 
	probit EEv i.hrmis0 i.pesex i.pemaritl0 i.peeduca0 i.age_grp if SlfPrx==`y' & (lf0==1 & lf1==1) [pweight=wgt]
}
	matrix V`x'_`y' = e(V)
	predict PEEvT if SlfPrx==`y' & (lf0==1 & lf1==1)
    replace PEEv = PEEvT if SlfPrx==`y' & (lf0==1 & lf1==1)
   	drop PEEvT
* The block below is for standard error 
 	predict PEEvT_xb if SlfPrx==`y' & (lf0==1 & lf1==1), xb
    replace PEEv_xb = PEEvT_xb if SlfPrx==`y' & (lf0==1 & lf1==1)
   	drop PEEvT_xb
	}
}
save, replace

clear
*Save var-cov matrix of the parameter estimates as the data file. 


if `x' >=200701{
foreach y of numlist 1/5{
svmat V`x'_`y'
save  V`x'_`y'.dta, replace
clear 
}
}

}
local x = `x' + 1
if (`x'-13)/100 == int((`x'-13)/100) {
    local x = `x' + 88
}
}

