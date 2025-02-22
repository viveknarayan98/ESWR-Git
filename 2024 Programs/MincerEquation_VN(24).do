
clear all
cls

**Mincer Equation**
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Data/Clean"

*Set file name as you need to
local filename fullcps0523

use if lnwage!=. & class_worker == 1 & inrange(age, 25, 55) using "`filename'", clear



* Generate variables		
gen time = ym(year, month)
format time %tm

tsset cpsidp time

tab married, gen(marital)
tab occ_g, gen(occupation)
tab LineCode, gen(lncode)
tab statefip, gen(state)
tab time, gen(DT_)
tab sex, gen(gender)
drop statefip
sum time
local maxtime = r(max)-r(min)+1


* ------------------------------------------------------------------------------
* Mincer (window)
* ------------------------------------------------------------------------------
qui summarize year
local iyear = r(min)
local lyear = r(max)

gen w_MINwindow = .
gen timecoef_MINwindow = .
gen constantcoef_MINwindow = .
local aux_ = 0


forvalues yy = `iyear'/`lyear' {
	forvalues mm = 1/12 {
		* multiply by hours
		display "year `yy' month `mm'"
		quietly {
			
		local aux_  = `aux_' +1
		local aux1_ = `aux_' +48
		local aux2_ = `aux_' -48
		local aux3_ = `aux_' + 1
		local aux4_ = `aux_' - 1
		
		if `aux_' == 1 {
			reg lnwage gradeate exp* sex* nWhite marital1 occupation* lncode* state* DT_`aux3_'-DT_`aux1_' [aw=earnwt*hours] if (year>`yy'-3  & year<`yy'+3) | (year==`yy'-4 & month>=`mm') | (year==`yy'+4  & month<=`mm')		      
			}
		else if `aux_' == `maxtime' {
			reg lnwage gradeate exp* sex* nWhite marital1 occupation* lncode* state* DT_`aux2_'-DT_`aux4_' [aw=earnwt*hours] if (year>`yy'-3  & year<`yy'+3) | (year==`yy'-4 & month>=`mm') | (year==`yy'+4  & month<=`mm')	
		}
		else {
		
			local aux1_ = min(`maxtime',`aux1_')
			local aux2_ = max(1,`aux2_')
			
		
			reg lnwage gradeate exp* sex* nWhite marital1 occupation* lncode* state* DT_`aux2_'-DT_`aux4_' DT_`aux3_'-DT_`aux1_' [aw=earnwt*hours] if (year>`yy'-3  & year<`yy'+3) | (year==`yy'-4 & month>=`mm') | (year==`yy'+4  & month<=`mm')	
		}
		
		replace timecoef_MINwindow= 0 if year==`yy' & month==`mm' & e(sample)==1
		replace constantcoef_MINwindow= _b[_cons] if year==`yy' & month==`mm' & e(sample)==1
		predict res if e(sample)==1, resid
		replace w_MINwindow = res if year==`yy' & month==`mm'
		drop res
		}
	}
}

		
	
* ------------------------------------------------------------------------------	
* Reg for the whole sample
* ------------------------------------------------------------------------------
* this didn't make sense at all
gen timecoef_MINwhole = .
gen constantcoef_MINwhole = .

quietly reg lnwage gradeate exp* sex* nWhite marital1 occupation* lncode* state* DT_* [aw=earnwt*hours] 
predict w_MINwhole if e(sample)==1, resid
replace constantcoef_MINwhole= _b[_cons]


local aux_ = 0
forvalues yy = `iyear'/`lyear' {
	forvalues mm = 1/12 {
		local aux_ = `aux_'+1
		replace timecoef_MINwhole= _b[DT_`aux_'] if year==`yy' & month==`mm' & e(sample)==1		
	}
}

keep cpsidp year month *_MINwindow *_MINwhole
merge 1:1 cpsidp year month using "`filename'"
drop _merge
sort cpsidp year month
save "`filename'mincer", replace

