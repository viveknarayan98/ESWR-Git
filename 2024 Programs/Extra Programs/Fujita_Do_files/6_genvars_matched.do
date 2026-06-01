clear all
set more off

cd "$dta"

use cps_all_matched.dta

sort hrhhid hrhhid2 pulineno startdate datem 

/*
*Household size.
NOTE. The following lines do not work for the period that hrhhid hrhhid2 do not uniquely identify household. 
The code runs but don't use the variable for the earlier period. 
*/
bys datem hrhhid hrhhid2: gen HHsize = _N
recode  HHsize (1=1) (2=2) (nonmiss = 3), gen(HHsizeI)
*nonmis = ">=3". 

*Marking of Self for all eight survey months
sort hrhhid hrhhid2 pulineno startdate datem 
gen S8=. 
bys hrhhid hrhhid2 pulineno startdate: replace S8 = (SlfPrx==1 & SlfPrx[_n+1] == 1  & SlfPrx[_n+2] == 1 & SlfPrx[_n+3]==1 & SlfPrx[_n+4] == 1  & SlfPrx[_n+5] == 1 &  hrmis0 == 1  & hrmis0[_n+1] == 2  & hrmis0[_n+2] == 3 &  hrmis0[_n+3] == 5  & hrmis0[_n+4] == 6  & hrmis0[_n+5] == 7 & startdate == startdate[_n+1]  & startdate == startdate[_n+2] & startdate == startdate[_n+3]  & startdate == startdate[_n+4] & startdate == startdate[_n+5])

sort hrhhid hrhhid2 pulineno startdate datem 
bys hrhhid hrhhid2 pulineno startdate: egen S8T = max(S8)
gen EEvS8 = EEv if S8T==1
gen EEmS8 = EEm if S8T==1

*Marking of Self for four consecutive months
sort hrhhid hrhhid2 pulineno startdate datem 
gen S41=. 
bys hrhhid hrhhid2 pulineno startdate: replace S41 = (SlfPrx==1 & SlfPrx[_n+1] == 1  & SlfPrx[_n+2] == 1 &  hrmis0 == 1  & hrmis0[_n+1] == 2  & hrmis0[_n+2] == 3 &  startdate == startdate[_n+1]  & startdate == startdate[_n+2] & startdate == startdate[_n+3])
	 bys hrhhid hrhhid2 pulineno startdate: egen S41T = max(S41)

sort hrhhid hrhhid2 pulineno startdate datem 
gen S42=. 
bys hrhhid hrhhid2 pulineno startdate: replace S42 = (SlfPrx==1 & SlfPrx[_n+1] == 1  & SlfPrx[_n+2] == 1 &  hrmis0 == 5  & hrmis0[_n+1] == 6  & hrmis0[_n+2] == 7 &  startdate == startdate[_n+1]  & startdate == startdate[_n+2]  & startdate == startdate[_n+3])

bys hrhhid hrhhid2 pulineno startdate: egen S42T = max(S42)

gen S4T=S41T+S42T

gen EEvS4 = EEv if S4T==1
gen EEmS4 = EEm if S4T==1

*Create variables only based on the two-month sequence
tab(SlfPrx), generate(SP_D)

foreach x of numlist 1/5 {
gen  JJ`x'  = JJ*SP_D`x'
gen  EEv`x'  = EEv*SP_D`x'
gen  EEm`x'  = EEm*SP_D`x'
gen  EU`x'  = EU*SP_D`x'
gen  EN`x' = EN*SP_D`x'
}

**Create UE series
gen UE  = (lf0==2 & lf1==1)
gen UU  = (lf0==2 & lf1==2)
gen UN = (lf0==2  & lf1==3)
gen NE  = (lf0==3  & lf1==1)

foreach x of numlist 1/5 {
gen  UE`x'  = UE*SP_D`x' 
gen  UU`x'  = UU*SP_D`x' 
gen  UN`x'  = UN*SP_D`x' 
}

gen     RIPFLAG = 0
replace RIPFLAG = 1 if datem      >= tm(2007m1) & datem <= tm(2007m12)
replace RIPFLAG = 1 if datem == tm(2008m1) & (startdate == tm(2007m12) | startdate == tm(2007m11) | startdate == tm(2007m10) | startdate == tm(2007m1) | startdate == tm(2006m12) | startdate == tm(2006m11)| startdate == tm(2006m10))
replace RIPFLAG = 1 if datem == tm(2008m2) & (startdate == tm(2007m12) | startdate == tm(2007m11) | startdate == tm(2007m2) | startdate == tm(2007m1) | startdate == tm(2006m12) | startdate == tm(2006m11))
replace RIPFLAG = 1 if datem == tm(2008m3) & (startdate == tm(2007m12) | startdate == tm(2007m3) | startdate == tm(2007m2)  | startdate == tm(2007m1) | startdate == tm(2006m12))
replace RIPFLAG = 1 if datem == tm(2008m4) & (startdate == tm(2007m4) | startdate == tm(2007m3) | startdate == tm(2007m2)   | startdate == tm(2007m1))
replace RIPFLAG = 1 if datem == tm(2008m5) & (startdate == tm(2007m5) | startdate == tm(2007m4) | startdate == tm(2007m3)   | startdate == tm(2007m2))
replace RIPFLAG = 1 if datem == tm(2008m6) & (startdate == tm(2007m6) | startdate == tm(2007m5) | startdate == tm(2007m4)   | startdate == tm(2007m3))
replace RIPFLAG = 1 if datem == tm(2008m7) & (startdate == tm(2007m7) | startdate == tm(2007m6) | startdate == tm(2007m5)   | startdate == tm(2007m4))
replace RIPFLAG = 1 if datem == tm(2008m8) & (startdate == tm(2007m8) | startdate == tm(2007m7) | startdate == tm(2007m6)   | startdate == tm(2007m5))
replace RIPFLAG = 1 if datem == tm(2008m9) & (startdate == tm(2007m9) |startdate == tm(2007m8)  | startdate == tm(2007m7)   | startdate == tm(2007m6))
replace RIPFLAG = 1 if datem == tm(2008m10)& (startdate == tm(2007m10)|startdate == tm(2007m9)  | startdate == tm(2007m8)   | startdate == tm(2007m7))
replace RIPFLAG = 1 if datem == tm(2008m11)& (startdate == tm(2007m11)|startdate == tm(2007m10) | startdate == tm(2007m9)   | startdate == tm(2007m8))
replace RIPFLAG = 1 if datem == tm(2008m12)& (startdate == tm(2007m12)|startdate == tm(2007m11) | startdate == tm(2007m10)  | startdate == tm(2007m9))
replace RIPFLAG = 1 if datem == tm(2009m1) & 	(startdate == tm(2007m12)| startdate == tm(2007m11)  | startdate == tm(2007m10))
replace RIPFLAG = 1 if datem == tm(2009m2) & 	(startdate == tm(2007m12)  | startdate == tm(2007m11))
replace RIPFLAG = 1 if datem == tm(2009m3) &	(startdate == tm(2007m12))


replace RIPFLAG = 2 if datem >= tm(2009m4)
replace RIPFLAG = 2 if datem == tm(2008m1)  & (startdate == tm(2008m1))
replace RIPFLAG = 2 if datem == tm(2008m2)  & (startdate == tm(2008m2) | startdate == tm(2008m1))
replace RIPFLAG = 2 if datem == tm(2008m3)  & (startdate == tm(2008m3) | startdate == tm(2008m2) | startdate == tm(2008m1))
replace RIPFLAG = 2 if datem == tm(2008m4)  & (startdate == tm(2008m4)  | startdate == tm(2008m3) | startdate == tm(2008m2) | startdate == tm(2008m1))
replace RIPFLAG = 2 if datem == tm(2008m5)  & (startdate == tm(2008m5)   | startdate == tm(2008m4)  | startdate == tm(2008m3) | startdate == tm(2008m2))
replace RIPFLAG = 2 if datem == tm(2008m6)  & (startdate == tm(2008m6)   | startdate == tm(2008m5)  | startdate == tm(2008m4) | startdate == tm(2008m3))
replace RIPFLAG = 2 if datem == tm(2008m7)  & (startdate == tm(2008m7)   | startdate == tm(2008m6)  | startdate == tm(2008m5) | startdate == tm(2008m4))
replace RIPFLAG = 2 if datem == tm(2008m8)  & (startdate == tm(2008m8)   | startdate == tm(2008m7)  | startdate == tm(2008m6) | startdate == tm(2008m5))
replace RIPFLAG = 2 if datem == tm(2008m9)  & (startdate == tm(2008m9)   | startdate == tm(2008m8)  | startdate == tm(2008m7) | startdate == tm(2008m6))
replace RIPFLAG = 2 if datem == tm(2008m10) & (startdate == tm(2008m10)   | startdate == tm(2008m9)  | startdate == tm(2008m8) | startdate == tm(2008m7))
replace RIPFLAG = 2 if datem == tm(2008m11) & (startdate == tm(2008m11)   | startdate == tm(2008m10)  | startdate == tm(2008m9) | startdate == tm(2008m8))
replace RIPFLAG = 2 if datem == tm(2008m12) &  (startdate == tm(2008m12)   | startdate == tm(2008m11)  | startdate == tm(2008m10) | startdate == tm(2008m9))
replace RIPFLAG = 2 if datem == tm(2009m1) &  (startdate == tm(2009m1)   | startdate == tm(2008m12)  | startdate == tm(2008m11) | startdate == tm(2008m10) | startdate == tm(2008m1))
replace RIPFLAG = 2 if datem == tm(2009m2) &  (startdate == tm(2009m2)   | startdate == tm(2009m1)  | startdate == tm(2008m12) | startdate == tm(2008m11) | startdate == tm(2008m2) | startdate == tm(2008m1))
replace RIPFLAG = 2 if datem == tm(2009m3) & (startdate == tm(2009m3) | startdate == tm(2009m2)   | startdate == tm(2009m1)    | startdate == tm(2008m12) | startdate == tm(2008m3) | startdate == tm(2008m2) | startdate == tm(2008m1))


* Create variables regarding hours 
 
gen hours0 = . 
replace hours0 = -4 if pehrusl10==-4
replace hours0 = 1 if  (pehrusl10>=0  & pehrusl10<=99)  

gen hours1 = . 
replace hours1 = -4 if pehrusl11==-4
replace hours1 = 1 if  (pehrusl11>=0  & pehrusl11<=99)  

assert (hours0~=. & hours1~=.) if EE==1
*Verify that if a worker is employed both months, information about hours is not missing for both months

tab hours0 hours1
tab hours0 hours1 if EEv==1
tab hours0 hours1 if EEm==1
*Just check the relationship between hours0/hours1 and EEv(EEm)


replace pehrusl10 =. if pehrusl10 ==-1 
replace pehrusl11 =. if pehrusl11 ==-1 
* Just want to get rid of -1, should be . (missing)

gen hours_change = . 
replace hours_change = 0 if  pehrusl10 == pehrusl11 & pehrusl10~=. & pehrusl11~=. &  pehrusl10~=-4 & pehrusl11~=-4
replace hours_change = 1 if  pehrusl10 == pehrusl11 & pehrusl10~=. & pehrusl11~=. &  pehrusl10==-4 & pehrusl11==-4
replace hours_change = 2 if pehrusl10 < pehrusl11 & hours0~=-4 & hours1~=-4 & pehrusl10~=. & pehrusl11~=.
replace hours_change = 3 if pehrusl10 > pehrusl11 & pehrusl10~=-4 & pehrusl11~=-4 & pehrusl10~=. & pehrusl11~=.
replace hours_change = 4 if  hours0 ==-4  & hours1 == 1 & pehrusl10~=. & pehrusl11~=.
replace hours_change = 5 if  hours1 ==-4  & hours0 == 1 & pehrusl10~=. & pehrusl11~=.


gen hoursI0 = .
replace hoursI0 = 1 if pehrusl10 == -4
replace hoursI0 = 2 if pehrusl10 == 40
replace hoursI0 = 3 if pehrusl10 < 40 &pehrusl10>=0
replace hoursI0 = 4 if pehrusl10 >40 & pehrusl10~=.


gen hoursI1 = .
replace hoursI1 = 1 if pehrusl11 == -4
replace hoursI1 = 2 if pehrusl11 == 40
replace hoursI1 = 3 if pehrusl11 < 40 & pehrusl11>=0
replace hoursI1 = 4 if pehrusl11 >40 & pehrusl11~=.

save cps_matched_all_additional_vars.dta, replace




