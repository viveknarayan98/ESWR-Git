* ------------------------------------------------------------------------------
* Imputewages.do: imputes wages for topcoded observations in the CPS microdata
* ------------------------------------------------------------------------------
* This version: May 2022
* ------------------------------------------------------------------------------

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"
cd "${mypath}/Data/Clean"

*-----------------------------------------------------------------------
* Load data
*-----------------------------------------------------------------------

*Set the filename to whatever year period you are using 

use fullcps, clear

*Must do this to avoid MORG data (which is not topcoded)

keep if year>=1982

*impute the top coded earnings- the top coded earnings are 1923 for 1989-1997 and 2884.61 for 1998 onwards*

qui summarize year
	local iyear = r(min)	
	local lyear = r(max)
	

foreach year of numlist `iyear'/`lyear' {
	foreach month of numlist 1/12 {
	
		display "year =`year' month= `month'"
		
		*Keep relevant variables
		quietly {
		clear 
		use earnweek l_status  class_worker cpsidp year month earnwt if year==`year' & month == `month' using fullcps
		
		*Keep employed workers
		if _N>0 {
		gen lnwke = ln(earnweek) if l_status==1 & class_worker!=0
	
	
		* top-code by year
		if 1979<=`year' & `year'<=1988 {
			global topcode=999 
		}
		
		if 1989<=`year' & `year'<=1997 {
			global topcode=1923 
		}
		
		if 1998<=`year' {
			global topcode=2884.61 
		}
		local T=ln($topcode) 

		*********************************************************************************
		* Step 1
		*********************************************************************************

		* a. calculate share of weekly earnings at or above the top-code (PHI)
		*    universe is all those not paid by hour and reporting weekly earnings
		*    not paid by hour is paidhre==2 in NBER data, ==0 in modified data

		gen     tci = 0 if l_status == 1 & class_worker!=0 & earnweek>0
		replace tci = 1 if l_status == 1 & class_worker!=0 & earnweek!=. & earnweek>=$topcode
		
		qui sum tci [aw=earnwt]
		local PHI = 1-r(mean)
		
		* b. calculate other needed values
		* 	 top-coding implies right-censoring
		*    take natural log of weekly earnings since procedure
		*    assumes weekly earnings are log-normalally distributed
		sum lnwke [aw=earnwt] if tci~=. 
		
		local X     = r(mean) 
		local SD    = r(sd) 
		local alpha = invnormal(`PHI')
		local lamda = -normalden(`alpha')/normal(`alpha')

		* c. calculate estimates of true mean and standard deviation
		local lsigma = (`T'-`X')/(`PHI'*(`alpha'-`lamda'))
		local lmu    = `T' - `alpha'*`lsigma'
		
		* d. convert from natural logs back to dollars per week
		local mX=exp(`X')
		local mu=exp(`lmu')
		local mT=exp(`T')
		local sigma=exp(`lsigma')

		*********************************************************************************
		* Step 2
		*********************************************************************************

		* a. calculate mean above top-code
		*    calculating mean above top-code implies left-truncation
		local halpha = (`T'-`lmu')/`lsigma'
		local hlamda = normalden(`halpha')/(1 - normal(`halpha'))
		local mtc    = `lmu' + `lsigma'*`hlamda'
		
		* b. convert from natural logs back to dollars per week
		qui replace earnweek = exp(`mtc') if tci==1
		
		* Drop 0.25th and 0.9975th percentile
		egen low_pw = pctile(earnweek) if year==`year' & month==`month', p(0.25)
		egen high_pw = pctile(earnweek) if year==`year' & month==`month', p(99.75)
		replace earnweek = . if (earnweek <= low_pw | earnweek >= high_pw) & year==`year' & month==`month'
		
		* Drop variables
		keep cpsidp year month earnweek
		
		if `year'==`iyear' & `month' == 1 {
			save imputed_wages, replace
		}
		else {
			append using imputed_wages
			save imputed_wages, replace
		}
		}
		}
	}
		
}
		

* Merge with fullcpsdata (microdata)
use imputed_wages, clear
ren earnweek earnweek_i
sort cpsidp year month
save imputed_wages, replace 

use fullcps, clear
if `iyear'==1979{
	drop hourslw_morg earnwt_morg earnhre_morg earnwke_morg ahrsworkt uhrswork1 uhrsworkorg trimdescrip Description CPS_Description union cpsid
}
else{
	drop ahrsworkt uhrswork1 uhrsworkorg trimdescrip Description CPS_Description union cpsid
	
}

*There is one duplicate with a missing cpsidp
duplicates report year month cpsidp

duplicates drop year month cpsidp, force

merge 1:1 cpsidp year month using imputed_wages
drop _merge

* Need to set up pre 1982 wages
replace earnweek_i = earnweek if year<=1981

*Generate wages variable
gen wage = earnweek_i/hours
gen lnwage = log(wage)	

* Save
save fullcps, replace 
erase imputed_wages.dta
