*****This file executes the macro regression***

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Programs/ESWR-Git/Data/Clean"

local quarterly=1

*Appending all the collapsed and merged CPS files

if `quarterly'==0{
	use merged_cps_annual, clear
	rename year time
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
gen lnwage = ln(wage)
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

/*
if `quarterly'==0{
	save merged_cps_annual, replace
}
else{
	save merged_cps_quarterly, replace
}
*/


*Mean EMP is weight
egen double mean_EMP = mean(EmploymentCPS), by(LineCode)

*Run regression***

gen lsepr = log(EU/(EU+EN+EE))
gen lseprt = log((EU+EN)/(EU+EN+EE))

egen trend=group(time)

if `quarterly'==1{
egen trend2= group(year)
}

****SEP REGRESSIONS*
*Regression with trend and weights (BASELINE)
reg F.lsepr c.trend##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage lprod wrigid [iw=EmploymentCPS], robust 

*With nominal wage and inflation


reg F.lsepr c.trend##i.LineCode  age education* nWhite male unionm unionc GDP_G lnwage lprod wrigid lprice F.lprice [iw=EmploymentCPS], robust 



*Regression with year trend
if `quarterly'==1{
reg F.lsepr c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage lprod wrigid [iw=EmploymentCPS], robust 
}

*Change in LHS var (not significant for wages but signs remain the same)
reg F.lsep c.trend##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage lprod wrigid [iw=EmploymentCPS], robust 

*With d.lprod, d.lprice
reg F.lsepr c.trend##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage lprod wrigid d.lprod d.lprice [iw=EmploymentCPS], robust 

*No weights
xtreg F.lsepr c.trend##i.LineCode  i.time age education* nWhite male unionm unionc GDP_G lrwage lprod wrigid, fe robust cluster(LineCode)


**PROD REGRESSIONS**
*Baseline
xtreg F.lprod c.trend##i.LineCode i.time age education* nWhite male unionm unionc GDP_G lrwage lsep  wrigid, fe robust cluster(LineCode)

*Year trend
if `quarterly'==1{
xtreg F.lprod c.trend2##i.LineCode age education* nWhite male unionm unionc GDP_G lrwage lsep  wrigid, fe robust cluster(LineCode)
}

*No trend
xtreg F.lprod  i.time age education* nWhite male unionm unionc GDP_G lrwage lsep  wrigid, fe robust cluster(LineCode)

*With weights
reg F.lprod c.trend##i.LineCode i.time age education* nWhite male unionm unionc GDP_G lrwage lsep  wrigid [iw=EmploymentCPS], robust







/*


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
*/

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

capture ssc install estout, replace
eststo clear
 
*---------------- SEP REGRESSIONS ----------------------------*
* Baseline: trend + weights
eststo sep1: reg F.lsepr c.trend##i.LineCode age education* nWhite male ///
    unionm unionc GDP_G lrwage lprod wrigid [iw=EmploymentCPS], robust
scalar Nbase_sep = e(N)
 
* Nominal wage + inflation
capture drop lnwage
gen lnwage = ln(wage)
eststo sep2: reg F.lsepr c.trend##i.LineCode age education* nWhite male ///
    unionm unionc GDP_G lnwage lprod wrigid lprice F.lprice [iw=EmploymentCPS], robust
 
* Year trend (quarterly only)
local sepq ""
if `quarterly'==1 {
    eststo sep3: reg F.lsepr c.trend2##i.LineCode age education* nWhite male ///
        unionm unionc GDP_G lrwage lprod wrigid [iw=EmploymentCPS], robust
    local sepq "sep3"
    local sepqt `""Year trend""'
}
 
* LHS in levels (lsep)
eststo sep4: reg F.lsep c.trend##i.LineCode age education* nWhite male ///
    unionm unionc GDP_G lrwage lprod wrigid [iw=EmploymentCPS], robust
 
* With D.lprod, D.lprice
eststo sep5: reg F.lsepr c.trend##i.LineCode age education* nWhite male ///
    unionm unionc GDP_G lrwage lprod wrigid d.lprod d.lprice [iw=EmploymentCPS], robust
 
* No weights, FE
eststo sep6: xtreg F.lsepr c.trend##i.LineCode i.time age education* nWhite male ///
    unionm unionc GDP_G lrwage lprod wrigid, fe robust cluster(LineCode)
 
esttab sep1 sep2 `sepq' sep4 sep5 sep6 using "sep_table.tex", replace ///
    keep(lrwage lnwage lprod wrigid) order(lrwage lnwage lprod wrigid) ///
    varlabels(lrwage "Log real wage" lnwage "Log nominal wage" ///
              lprod "Log productivity" wrigid "Wage rigidity") ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc 3) labels("Observations" "\$R^2\$")) ///
    mtitles("Baseline" "Nominal wage" `sepqt' "LHS in levels" "With \$\Delta\$ controls" "No weights") ///
    title("Determinants of separations\label{tab:sep}") ///
    booktabs nonumbers nonotes label ///
    addnotes("Standard errors in parentheses. * \$p<0.10\$, ** \$p<0.05\$, *** \$p<0.01\$." ///
             "Baseline (column 1) estimated on `=scalar(Nbase_sep)' observations.")
 
*---------------- PROD REGRESSIONS ---------------------------*
* Baseline
eststo prod1: xtreg F.lprod c.trend##i.LineCode i.time age education* nWhite male ///
    unionm unionc GDP_G lrwage lsep wrigid, fe robust cluster(LineCode)
scalar Nbase_prod = e(N)
 
* Year trend (quarterly only)
local prodq ""
if `quarterly'==1 {
    eststo prod2: xtreg F.lprod c.trend2##i.LineCode age education* nWhite male ///
        unionm unionc GDP_G lrwage lsep wrigid, fe robust cluster(LineCode)
    local prodq "prod2"
    local prodqt `""Year trend""'
}
 
* No trend
eststo prod3: xtreg F.lprod i.time age education* nWhite male ///
    unionm unionc GDP_G lrwage lsep wrigid, fe robust cluster(LineCode)
 
* Weights
eststo prod4: reg F.lprod c.trend##i.LineCode i.time age education* nWhite male ///
    unionm unionc GDP_G lrwage lsep wrigid [iw=EmploymentCPS], robust
 
esttab prod1 `prodq' prod3 prod4 using "prod_table.tex", replace ///
    keep(lrwage lsep wrigid) order(lrwage lsep wrigid) ///
    varlabels(lrwage "Log real wage" lsep "Log separations" wrigid "Wage rigidity") ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc 3) labels("Observations" "\$R^2\$")) ///
    mtitles("Baseline" `prodqt' "No trend" "Weighted") ///
    title("Determinants of productivity\label{tab:prod}") ///
    booktabs nonumbers nonotes label ///
    addnotes("Standard errors in parentheses. * \$p<0.10\$, ** \$p<0.05\$, *** \$p<0.01\$." ///
             "Baseline (column 1) estimated on `=scalar(Nbase_prod)' observations.")
 
eststo clear



