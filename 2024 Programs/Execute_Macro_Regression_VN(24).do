*****This file executes the macro regression***

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Programs/ESWR-Git/Data/Clean"

local quarterly=0

*Appending all the collapsed and merged CPS files

if `quarterly'==0{
	use merged_cps_annual, clear
}
else{
	use merged_cps_quarterly, clear
}


*Set panel and time vars
xtset LineCode time
 
*Create productivity and inflation measures


*gen prodh_i = GDP/thours
*gen lprod= log(prodh_i)
*gen lprice= log(price_i)
*gen wrigid = wchange0/(wchange0 + wchangen)

gen lrwage = log(wage/price_i)
gen lsep   = log(EU)
gen lhiresu = log(UE)
gen lhires = log(UE+NE)
gen lsep_a = log(EU+EN)
gen lprod4 = log(GDP/(thours))
gen lrwage_rig = lrwage*wrigid
gen lprod_rig = lprod*wrigid
gen dlrwage = d.lrwage
gen dlprod  = d.lprod
gen dlsep   = d.lsep
gen dlrwage_rig = d.lrwage_rig
gen dlprod_rig  = d.lprod_rig
gen dlrwage_rig2 = d.lrwage*L.wrigid
gen dlprod_rig2  = d.lprod*L.wrigid

gen GDP_G = log(GDP) - log(L.GDP)

if `quarterly'==0{
	save merged_cps_annual, replace
}
else{
	save merged_cps_quarterly, replace
}


*Mean GDP is weight
egen double mean_EMP = mean(EmploymentCPS), by(LineCode)

*Run regression***

*With log separations
xtreg F.lsep   i.time age education* nWhite male unionm unionc GDP_G lrwage lprod wrigid, fe robust cluster(LineCode)
xtreg F.lprod  i.time age education* nWhite male unionm unionc GDP_G lrwage lsep  wrigid, fe robust cluster(LineCode)

* 0) Panel/time setup (adjust names if yours differ)
xtset LineCode time

* 1) Build an output file to store rolling-window estimates
tempfile roll_lprod
tempname postH
postfile `postH' int t_start int t_end double t_mid ///
    double b_lrwage double se_lrwage double N using "`roll_lprod'", replace

* 2) Define the time range (assumes integer yearly time)
quietly summarize time, meanonly
local tmin = r(min)
local tmax = r(max)

* 3) Loop over 5-year windows [t, t+4]
forvalues t = `tmin'(1)`=`tmax'-4' {
    local t2 = `t' + 4

    * Run your FE regression in the current window
    * (clustered by LineCode, analytic weights mean_GDP)
    capture noisily xtreg F.lsep   i.time age education* nWhite male ///
        unionm unionc GDP_G lrwage lprod wrigid [aw=mean_GDP] ///
        if inrange(time, `t', `t2'), fe vce(cluster LineCode)

    * If the regression failed (too few obs, perfect collinearity, etc.), skip
    if _rc continue

    * Pull coefficient/SE for lprod if it survived this window
    local b  = .
    local se = .
    local N  = e(N)

    * Check whether lprod is in e(b)
    local cols : colnames e(b)
    local pos  : list posof "lrwage" in cols
    if `pos' {
        local b  = _b[lrwage]
        local se = _se[lrwage]
    }

    * Save this window's result
    post `postH' (`t') (`t2') ((`t'+`t2')/2) (`b') (`se') (`N')
}

postclose `postH'

* 4) Bring the results into memory and set up as a time series
use "`roll_lprod'", clear
rename (t_start t_end t_mid) (tstart tend t)
tsset t

* Optional: confidence bands and a quick plot
gen ub = b_lrwage + 1.96*se_lrwage
gen lb = b_lrwage - 1.96*se_lrwage
tsline b_lrwage lb ub, yline(0) legend(order(1 "b[lprod]" 2 "95% CI"))

* Keep a handle to your rolling results
tempfile roll_keep
save "`roll_keep'", replace

*---------------------------------------------
* 1) Import FRED unemployment (UNRATE) from 1979+
*---------------------------------------------
import fred UNRATE, clear
* Harmonize the time variable to monthly date 'mdate'
gen year = substr(datestr, 1, 4)
destring year, replace

collapse (mean) UNRATE, by(year)

*---------------------------------------------
* 2) Create 5-year rolling averages aligned to [tstart, tend] = [year, year+4]
*---------------------------------------------
tsset year
tssmooth ma unrate5 = UNRATE, window(0 1 4)    // average of year..year+4

* Keep only complete 5y windows
keep if !missing(unrate5)

* Create window identifiers to match rolling regression windows
gen tstart = year
gen tend   = year + 4
gen t      = (tstart + tend) / 2

keep tstart tend t unrate5
tempfile unrate5
save "`unrate5'", replace

*---------------------------------------------
* 3) Merge with your rolling regression output
*---------------------------------------------
use "`roll_keep'", clear
merge 1:1 tstart tend using "`unrate5'", nogen

*---------------------------------------------
* 4) Scatter plot: lprod coefficient vs. 5y avg unemployment
*---------------------------------------------
twoway ///
 (scatter unrate5 b_lrwage, msymbol(o) msize(medlarge)) ///
 (lfit    unrate5 b_lrwage), ///
 yline(0, lpattern(dash)) ///
 ytitle("Unemployment rate (5-year rolling average, %)") ///
 xtitle("Coefficient on lrwage") ///
 title("Rolling 5-year: lrwage coeff vs unemployment") ///
 legend(order(1 "Window points" 2 "Linear fit")) ///
 xlabel(, grid) ylabel(, grid)

*if `quarterly'==0{
	*rename time year
	*save merged_cps_annual, replace
*}

/*
*With separations rate

gen sep_rate = EU/L.empdenom


*Create Wage Rigidty Figure
collapse(sum) wchangen wchange0 wchangep EU, by(year)

gen wrigid= wchange0/(wchangen+wchangep+EU+wchange0)*100

keep if time>1979

tsset time

label var wrigid "Wage Rigidity"
label var time "Year"

tsline wrigid
*/



