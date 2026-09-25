*****This file executes the macro regression***
* Housekeeping
clear
cls

* Declare user
global user = "c"

* Global folder
if "$user"=="v" {
	global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"
}
if "$user"=="c" {
	global mypath "/mq/scratch/m1cxm05/ESWR"
}

* Login into folder
cd "${mypath}/Data/Clean"

* Load data
use merged_cps_quarterly, clear

*Set panel and time vars
tsset LineCode time
 
*Create productivity and inflation measures
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
egen trend = group(time)
gen trend2 = trend^2

gen lsepr      = log(EU/(EU+EN+EE))
gen lseprt     = log((EU+EN)/(EU+EN+EE))
gen DEN        = EU+EN+EE
gen prodgrowth = d.lprod
gen inflation_lc  = d.lprice


*---------------- PROGRAMS FOR HORIZON-COEFFICIENT PLOTS ----------------*
global graphpath "/if/research-afe/joaquin/wage rigidity/Empirical programs"

capture program drop horizon_coefs
program define horizon_coefs, rclass
    syntax, depvar(string) rhs(string) wtvar(string) covars(string)
    tempname results
    matrix `results' = J(4, 2*wordcount("`covars'"), .)
    forvalues h = 1/4 {
        quietly reg F`h'.`depvar' `rhs' [iw=`wtvar'], robust
        local col = 1
        foreach v of local covars {
            matrix `results'[`h', `col']   = _b[`v']
            matrix `results'[`h', `col'+1] = _se[`v']
            local col = `col' + 2
        }
    }
    return matrix results = `results'
end

capture program drop plot_horizon_coef
program define plot_horizon_coef
    syntax, matname(string) col(integer) ytitle(string) title(string) filename(string)
    preserve
    clear
    set obs 4
    gen horizon = _n
    gen b  = .
    gen se = .
    forvalues h = 1/4 {
        replace b  = el(`matname', `h', `col')   if horizon==`h'
        replace se = el(`matname', `h', `col'+1) if horizon==`h'
    }
    gen ci_lo90 = b - 1.645*se
    gen ci_hi90 = b + 1.645*se

    twoway (rcap ci_lo90 ci_hi90 horizon, lcolor(gs8) lwidth(medium)) ///
           (connected b horizon, mcolor(navy) lcolor(navy) msymbol(circle) msize(medium)), ///
        xlabel(1 "t+1" 2 "t+2" 3 "t+3" 4 "t+4", noticks) ///
        xtitle("Forecast horizon (quarters ahead)") ///
        ytitle("`ytitle'") ///
        title("`title'") ///
        yline(0, lpattern(dash) lcolor(black)) ///
        legend(order(2 "Point estimate" 1 "90% CI") pos(6) rows(1)) ///
        graphregion(color(white)) plotregion(color(white)) scheme(s2color)

    graph export "${graphpath}/`filename'", replace width(2000)
    restore
end

local rhs_common "i.time c.trend##i.LineCode c.trend2##i.LineCode age education* nWhite male unionm unionc GDP_G"
local rhs_A "`rhs_common' lrwage lprod wrigid prodgrowth inflation_lc"
local rhs_B "`rhs_common' lrwage lseprt wrigid prodgrowth inflation_lc"

*---------------- lsepr REGRESSIONS ----------------*
reg F.lsepr i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F2.lsepr i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F3.lsepr i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F4.lsepr i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust

horizon_coefs, depvar(lsepr) rhs("`rhs_A'") wtvar(DEN) covars("lrwage lprod inflation_lc")
matrix M_lsepr = r(results)
plot_horizon_coef, matname(M_lsepr) col(1) ytitle("Coefficient on log real wage") title("Real wage effect on separation rate, by horizon") filename("lrwage_lsepr_horizon.png")
plot_horizon_coef, matname(M_lsepr) col(3) ytitle("Coefficient on log productivity") title("Productivity effect on separation rate, by horizon") filename("lprod_lsepr_horizon.png")
plot_horizon_coef, matname(M_lsepr) col(5) ytitle("Coefficient on inflation") title("Inflation effect on separation rate, by horizon") filename("inflation_lsepr_horizon.png")

*---------------- lseprt REGRESSIONS ----------------*
reg F.lseprt i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F2.lseprt i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F3.lseprt i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F4.lseprt i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust

horizon_coefs, depvar(lseprt) rhs("`rhs_A'") wtvar(DEN) covars("lrwage lprod inflation_lc")
matrix M_lseprt = r(results)
plot_horizon_coef, matname(M_lseprt) col(1) ytitle("Coefficient on log real wage") title("Real wage effect on separation rate (broad), by horizon") filename("lrwage_lseprt_horizon.png")
plot_horizon_coef, matname(M_lseprt) col(3) ytitle("Coefficient on log productivity") title("Productivity effect on separation rate (broad), by horizon") filename("lprod_lseprt_horizon.png")
plot_horizon_coef, matname(M_lseprt) col(5) ytitle("Coefficient on inflation") title("Inflation effect on separation rate (broad), by horizon") filename("inflation_lseprt_horizon.png")

*---------------- lprod REGRESSIONS ----------------*
reg F.lprod i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lseprt wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F2.lprod i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lseprt wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F3.lprod i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lseprt wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F4.lprod i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lseprt wrigid prodgrowth  inflation_lc [iw=DEN ], robust

horizon_coefs, depvar(lprod) rhs("`rhs_B'") wtvar(DEN) covars("lrwage lseprt inflation_lc")
matrix M_lprod = r(results)
plot_horizon_coef, matname(M_lprod) col(1) ytitle("Coefficient on log real wage") title("Real wage effect on productivity, by horizon") filename("lrwage_lprod_horizon.png")
plot_horizon_coef, matname(M_lprod) col(3) ytitle("Coefficient on log separation rate (broad)") title("Separation rate effect on productivity, by horizon") filename("lseprt_lprod_horizon.png")
plot_horizon_coef, matname(M_lprod) col(5) ytitle("Coefficient on inflation") title("Inflation effect on productivity, by horizon") filename("inflation_lprod_horizon.png")

*---------------- lhires REGRESSIONS ----------------*
reg F.lhires i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F2.lhires i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F3.lhires i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F4.lhires i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust

horizon_coefs, depvar(lhires) rhs("`rhs_A'") wtvar(DEN) covars("lrwage lprod inflation_lc")
matrix M_lhires = r(results)
plot_horizon_coef, matname(M_lhires) col(1) ytitle("Coefficient on log real wage") title("Real wage effect on hires rate, by horizon") filename("lrwage_lhires_horizon.png")
plot_horizon_coef, matname(M_lhires) col(3) ytitle("Coefficient on log productivity") title("Productivity effect on hires rate, by horizon") filename("lprod_lhires_horizon.png")
plot_horizon_coef, matname(M_lhires) col(5) ytitle("Coefficient on inflation") title("Inflation effect on hires rate, by horizon") filename("inflation_lhires_horizon.png")


*---------------- SUMMARY TABLE: KEY ONE-QUARTER-AHEAD MACRO REGRESSIONS ----------------*
cd "/if/research-afe/joaquin/wage rigidity/Empirical programs"
capture ssc install estout, replace
eststo clear

eststo m1: reg F.lsepr  i.time c.trend##i.LineCode c.trend2##i.LineCode age education* nWhite male unionm unionc GDP_G lrwage lprod  wrigid prodgrowth inflation_lc [iw=DEN], robust
eststo m2: reg F.lseprt i.time c.trend##i.LineCode c.trend2##i.LineCode age education* nWhite male unionm unionc GDP_G lrwage lprod  wrigid prodgrowth inflation_lc [iw=DEN], robust
eststo m3: reg F.lprod  i.time c.trend##i.LineCode c.trend2##i.LineCode age education* nWhite male unionm unionc GDP_G lrwage lseprt wrigid prodgrowth inflation_lc [iw=DEN], robust
eststo m4: reg F.lhires i.time c.trend##i.LineCode c.trend2##i.LineCode age education* nWhite male unionm unionc GDP_G lrwage lprod  wrigid prodgrowth inflation_lc [iw=DEN], robust

esttab m1 m2 m3 m4 using "macro_key_table.tex", replace ///
    keep(lrwage lprod lseprt wrigid prodgrowth inflation_lc) ///
    order(lrwage lprod lseprt wrigid prodgrowth inflation_lc) ///
    varlabels(lrwage "Log real wage" lprod "Log productivity" lseprt "Log separation rate (broad)" ///
              wrigid "Wage rigidity" prodgrowth "Productivity growth" inflation_lc "Inflation") ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc 3) labels("Observations" "\$R^2\$")) ///
    mtitles("Separation rate" "Separation rate (broad)" "Productivity" "Hires rate") ///
    title("Key macro regression results\label{tab:macro_key}") ///
    booktabs nonumbers nonotes label ///
    addnotes("Standard errors in parentheses. * \$p<0.10\$, ** \$p<0.05\$, *** \$p<0.01\$." ///
             "All columns also control for time fixed effects, LineCode-specific linear and quadratic trends, age, education, race, sex, and union membership/coverage, and are weighted by DEN.")

eststo clear


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
        unionm unionc GDP_G lrwage lprod wrigid [aw=mean_EMP] ///
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



