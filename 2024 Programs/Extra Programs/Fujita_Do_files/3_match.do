*Code to match individuals across adjacent months

clear all
set more off

cd "$dta"

local yearmth = 199401
local nextmonth = 199402

while `yearmth' <= 199508{

use cpsm`nextmonth'.dta

keep year month hrhhid hrhhid2 pulineno hrmis prunedur pruntype pemlr peeduca perace pesex peage gestcen pemaritl puretot pudis pehrusl1 pehrftpt pehrwant prwkstat puiodp* mjrocc mjrind prcow1 fweight pwlgwgt puslfprx peioicd peioocd prmjind1 prmjocc1 ocdest  prabsrea prdtcow prsjms

	/* Set up the variables in both months.*/
	rename year year1
	rename month month1
	rename hrmis hrmis1
	rename pemlr pemlr1
	rename prunedur prunedur1 
	rename pruntype pruntype1
	rename peeduca peeduca1
	rename gestcen gestcen1
	rename pemaritl pemaritl1
    rename pehrusl1 pehrusl11
	rename pehrftpt  pehrftpt1
 	rename pehrwant pehrwant1
	rename prwkstat prwkstat1 
	rename puiodp* puiodp*1 
	rename prcow1 prcow11 
	rename fweight fweight1 
    rename pwlgwgt pwlgwgt1 
	rename puslfprx puslfprx1
	rename puretot puretot1 
	rename pudis pudis1
	rename mjrocc mjrocc1 
	rename ocdest ocdest1 
	rename mjrind mjrind1
	rename peioicd peioicd1 
	rename peioocd peioocd1
	rename prmjind1 prmjind11
	rename prmjocc1 prmjocc11
	rename prabsrea prabsrea1 
	rename prdtcow prdtcow1 
	rename prsjms prsjms1 
	gen    ageinfo1  = peage 
	gen    sexinfo1  = pesex 
	gen    raceinfo1 = perace 
	
	
	

	sort hrhhid hrhhid2 pulineno peage pesex perace
	save using_dta, replace

use cpsm`yearmth'.dta

keep year month hrhhid hrhhid2 pulineno hrmis prunedur pruntype pemlr peeduca perace pesex peage gestcen pemaritl puretot pudis pehrusl1 pehrftpt pehrwant prwkstat puiodp* mjrocc mjrind prcow1 fweight pwlgwgt puslfprx peioicd peioocd prmjind1 prmjocc1 ocdest prabsrea prdtcow prsjms


	rename year year0
	rename month month0
	rename hrmis hrmis0
	rename pemlr pemlr0
	rename peeduca peeduca0
	rename prunedur prunedur0 
    rename pruntype pruntype0
	rename gestcen gestcen0
	rename pemaritl pemaritl0
    rename pehrusl1 pehrusl10
	rename pehrftpt pehrftpt0
 	rename pehrwant pehrwant0
	rename prwkstat prwkstat0 
	rename puiodp* puiodp*0 
	rename prcow1 prcow10 
	rename fweight fweight0
	rename pwlgwgt pwlgwgt0
	rename puretot puretot0
	rename pudis pudis0
	rename puslfprx puslfprx0
	rename mjrocc mjrocc0 
	rename mjrind mjrind0
	rename ocdest ocdest0 
	rename peioicd peioicd0 
	rename peioocd peioocd0
	rename prmjind1 prmjind10
	rename prmjocc1 prmjocc10
	rename prabsrea prabsrea0 
	rename prdtcow prdtcow0
	rename prsjms prsjms0
	gen    ageinfo0  = peage 
	gen    sexinfo0  = pesex 
	gen    raceinfo0 = perace 
	
	
	
	
	sort hrhhid hrhhid2 pulineno peage pesex perace 
	save orig_dta, replace
	
	merge hrhhid hrhhid2 pulineno peage pesex perace using using_dta
	
	rename _merge _merge1
		
	gen _merge_stage1 = _merge1	
	
	
	/* This is our initial merged dataset.*/
	save matched`yearmth', replace

		/* The key now is that in any given pair of months someone could change age. We
	need to allow for this, and so need to check for any merges that didn't happen
	just because the age in the second month increased by one. To do this we start 
	by making a dataset of those observations that just appeared in the second month,
	and decreasing their age by 1. */
	keep if _merge1==2
	replace peage = peage-1
	sort hrhhid hrhhid2 pulineno peage pesex perace
	save using_age, replace
	
	/* Next take those that appeared just in the first month, and attempt to merge 
	them with the previouly created dataset. */
	use matched`yearmth', clear
	keep if _merge1==1
	sort  hrhhid hrhhid2  pulineno peage pesex perace
	merge  hrhhid hrhhid2  pulineno peage pesex perace using using_age, update
	/*Drop anyone that still failed to match, as they still exist in the initial
	matched dataset, and add the newly merged guys onto the end of the initial. */

	
	*drop if _merge == 1 | _merge == 2
	
	save matched_age, replace
	
	clear
		
	use matched`yearmth'
	
	drop if _merge1 == 1 | _merge1 == 2
		
	append using matched_age
	
	
	replace _merge1=3 if _merge==5

************************************************************* 
*	drop if hrmis0==4 | hrmis0==8 | hrmis1==1 | hrmis1==5 
************************************************************* 	
	
	save matched`yearmth', replace
	local ++yearmth
	if ((`yearmth' - 13)/100) == int((`yearmth' - 13)/100){
		local yearmth = `yearmth' + 88
	}
	local ++nextmonth
	if ((`nextmonth' - 13)/100) == int((`nextmonth' - 13)/100){
		local nextmonth = `nextmonth' + 88
	}
}


while `yearmth' <=202211{

use cpsm`nextmonth'

keep year month hrhhid hrhhid2 pulineno hrmis prunedur pruntype pemlr peeduca perace pesex peage gestcen pemaritl puretot pudis pehrusl1 pehrftpt pehrwant prwkstat puiodp* mjrocc mjrind prcow1 fweight pwlgwgt puslfprx peioicd peioocd prmjind1 prmjocc1 ocdest prabsrea prdtcow prsjms
	
	
	rename year year1
	rename month month1
	rename hrmis hrmis1
	rename pemlr pemlr1
	rename peeduca peeduca1
	rename prunedur prunedur1 
	rename pruntype pruntype1
	rename gestcen gestcen1
	rename pemaritl pemaritl1
    rename pehrusl1 pehrusl11
	rename pehrftpt  pehrftpt1
 	rename pehrwant pehrwant1
	rename prwkstat prwkstat1 
	rename puiodp* puiodp*1 
	rename prcow1 prcow11 
	rename fweight fweight1 
	rename pwlgwgt pwlgwgt1 
	rename puretot puretot1 
	rename pudis pudis1
	rename puslfprx puslfprx1 
	rename mjrocc mjrocc1 
	rename mjrind mjrind1
	rename ocdest ocdest1
	rename peioicd peioicd1 
	rename peioocd peioocd1
	rename prmjind1 prmjind11
	rename prmjocc1 prmjocc11
	rename prabsrea prabsrea1 
	rename prdtcow prdtcow1 
	rename prsjms prsjms1 
	gen    ageinfo1  = peage 
	gen    sexinfo1  = pesex 
	gen    raceinfo1 = perace 
		
	

	sort hrhhid hrhhid2 pulineno 
	save using_dta, replace

	use cpsm`yearmth'

keep year month hrhhid hrhhid2 pulineno hrmis pemlr prunedur pruntype peeduca perace pesex peage gestcen pemaritl puretot pudis pehrusl1 pehrftpt pehrwant prwkstat puiodp* mjrind mjrocc prcow1 fweight pwlgwgt puslfprx peioicd peioocd prmjind1 prmjocc1 ocdest prabsrea prdtcow prsjms


	rename year year0
	rename month month0
	rename hrmis hrmis0
	rename pemlr pemlr0
	rename peeduca peeduca0
	rename prunedur prunedur0
	rename pruntype pruntype0
	rename gestcen gestcen0
	rename pemaritl pemaritl0
    rename pehrusl1 pehrusl10
	rename pehrftpt pehrftpt0
 	rename pehrwant pehrwant0
	rename prwkstat prwkstat0 
	rename puiodp* puiodp*0 
	rename prcow1 prcow10 
	rename fweight fweight0
	rename pwlgwgt pwlgwgt0 
	rename puretot puretot0 
	rename pudis pudis0
	rename puslfprx puslfprx0
	rename mjrocc mjrocc0
	rename mjrind mjrind0
	rename ocdest ocdest0 
	rename peioicd peioicd0 
	rename peioocd peioocd0
	rename prmjind1 prmjind10
	rename prmjocc1 prmjocc10
	rename prabsrea prabsrea0 
	rename prdtcow prdtcow0 
	rename prsjms prsjms0
	gen    ageinfo0  = peage 
	gen    sexinfo0  = pesex 
	gen    raceinfo0 = perace 
	
	
	sort hrhhid hrhhid2 pulineno 
	save orig_dta, replace
	
	/* Merge using only id variables */
	merge hrhhid hrhhid2 pulineno using using_dta
	
	rename _merge _merge1
	
	************************************************************* 
*	drop if hrmis0==4 | hrmis0==8 | hrmis1==1 | hrmis1==5 
	************************************************************* 	
	save matched`yearmth', replace

	local ++yearmth
	if ((`yearmth' - 13)/100) == int((`yearmth' - 13)/100){
		local yearmth = `yearmth' + 88
	}
	local ++nextmonth
	if ((`nextmonth' - 13)/100) == int((`nextmonth' - 13)/100){
		local nextmonth = `nextmonth' + 88
	}
}




