*----------------------------
* Load data and set panel
*----------------------------


use fullcps, clear

*drop if mish<4
*drop if year<1994
*drop if empstat<3

gen time= ym(year, month)
format time %tm

sort cpsidp time
xtset cpsidp time

*----------------------------
* 1. Age consistency:
*    Drop cpsidp if |age_change| > 2 (12-month diff, mishes 5–8)
*----------------------------
gen age_change = age - L12.age if inrange(mish, 5, 8)
	bys cpsidp: egen bad_age = max(abs(age_change) > 2 & !missing(age_change))

*----------------------------
* 2. Race consistency:
*    Drop cpsidp if nWhite ever changes
*----------------------------
	bys cpsidp: egen race_min = min(nWhite)
	bys cpsidp: egen race_max = max(nWhite)
	
gen race_change = (race_min != race_max) ///
                  & !missing(race_min) & !missing(race_max)

*----------------------------
* 3. Sex consistency:
*    Drop cpsidp if sex ever changes (1 ↔ 2)
*----------------------------
	bys cpsidp: egen sex_min = min(sex)
	bys cpsidp: egen sex_max = max(sex)

gen sex_change = (sex_min != sex_max) ///
                 & !missing(sex_min) & !missing(sex_max)

*----------------------------
* 4. Wage consistency:
*    Drop cpsidp if |wc| > 0.5 (12-month log wage change)
*----------------------------
gen wage   = earnweek / hours
gen lnwage = log(wage)
gen wc     = lnwage - L12.lnwage

	bys cpsidp: egen bad_wc = max(abs(wc) > 0.5 & !missing(wc))

*----------------------------
* 5. Employment stability rule:
*    Drop cpsidp if empsame == 1 in any of mish 6–8
*----------------------------
*	bys cpsidp: egen bad_empsame = max(empsame == 1 & inrange(mish, 6, 8))

*----------------------------
* Combine all exclusion rules
*----------------------------
gen drop_flag = bad_age | race_change | sex_change | bad_wc 

drop if drop_flag

*----------------------------
* Clean up helper variables
*----------------------------
drop age_change bad_age race_min race_max race_change ///
     sex_min sex_max sex_change wage lnwage wc bad_wc ///
      drop_flag

* Identifying job changers using empsame

*Note that this code marks the person as a job changer for all their observations if empsame indicates that

	bys cpsidp: egen job_changer = max(empsame == 1 & inrange(mish, 6, 8))

egen occ_ind_group = group (ind_g occ_g)
gen occ_ind_group_change = occ_ind_group - L9.occ_ind_group

*Here we note that happy_changer is an excellent proxy of 

* happy_changer = 1 in mish 5 if occ/ind group changes (and is not missing)
gen happy_changer = 0
replace happy_changer = 1 if mish == 5 ///
    & occ_ind_group_change != 0 ///
    & occ_ind_group_change != .
	
* Flag condition (a): happy_changer == 1 in mish 5
	bys cpsidp: egen flag_happy = max(happy_changer == 1 & mish == 5)

* Flag condition (b): empsame between 96 and 99 in mish 6–8
	bys cpsidp: egen flag_niu = max(inrange(empsame, 96, 99) & inrange(mish, 6, 8))

* Person-level indicator: job_changer_unknown
gen job_changer_unknown = (flag_happy | flag_niu)

* Optional: drop helper flags
drop flag_happy flag_niu

****ADD that people also need to be employed!!!***

*gen unemployed = inrange(empstat, 20, 22)
gen unemp_5_8 = (mish >= 5 & mish <= 8) & l_status==2
bysort cpsidp: egen ever_unemp_5_8 = max(unemp_5_8)

gen nlf_5_8 = (mish >= 5 & mish <= 8) & l_status==3
bysort cpsidp: egen ever_nlf_5_8 = max(nlf_5_8)


* For each cpsidp, check if they are EVER a job_changer or job_changer_unknown
	bys cpsidp: egen ever_job_move = ///
		max((job_changer == 1) | (job_changer_unknown == 1))

* Job stayer = 1 if they are NEVER either type in their lifetime
* Note that people that change jobs before mish 4 are still treated as job stayers
gen job_stayer = (ever_job_move == 0)



*Two cases
*1. Restrictive case- We filter out job changers and job changer unknown
*2. Less restrictive case- We filter out job changers (according to empsame) 

