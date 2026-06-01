clear all

****************************************************
* 1. Import data from FRED (GDP, productivity, recessions, inflation)
****************************************************
import fred GDPC1 OPHNFB USRECQ GDPDEF, clear

* Create quarterly date
gen qdate = qofd(daten)
format qdate %tq
tsset qdate, quarterly

* Focus on modern period
keep if qdate >= yq(1965,1)

****************************************************
* 2. Log levels + inflation
****************************************************
gen lgdp = ln(GDPC1)
gen lop  = ln(OPHNFB)

* Inflation: annualized q/q log change of GDP deflator (%)
gen inflation = 400 * (ln(GDPDEF) - ln(L.GDPDEF))
label var inflation "Inflation (GDPDEF, annualized q/q, %)"

****************************************************
* 3. Christiano–Fitzgerald band-pass filter
****************************************************
tsfilter cf cf_lgdp = lgdp
tsfilter cf cf_lop  = lop

label var cf_lgdp "CF band-pass cycle of log GDP"
label var cf_lop  "CF band-pass cycle of log productivity"

drop if missing(cf_lgdp, cf_lop)

****************************************************
* 4. Prepare for rolling correlation
****************************************************
gen obs = _n
tempfile base
save `base'

****************************************************
* 5. Rolling correlation of BP cycles (20-quarter window)
****************************************************
rolling rho = r(rho), window(20) saving(bproll, replace): ///
    correlate cf_lgdp cf_lop

use bproll, clear

* Align rolling window index with original sample
gen obs = _n + 20 - 1
merge 1:1 obs using `base', keep(match) nogen

****************************************************
* 6. Rebuild qdate after merge to avoid any misalignment
****************************************************
drop qdate
gen qdate = qofd(daten)
format qdate %tq
tsset qdate, quarterly

keep if qdate >= yq(1965,1)

****************************************************
* 6b. Build 20-quarter rolling average inflation (after merge)
****************************************************
gen infl_20q = .
quietly forvalues i = 20/`=_N' {
    qui summarize inflation in `=`i'-19'/`i', meanonly
    replace infl_20q = r(mean) in `i'
}
label var infl_20q "Inflation (20q rolling avg, annualized q/q, %)"

****************************************************
* 7. Recession shading variable (blog style)
****************************************************
keep if rho < .

summarize rho

gen recession = r(max) if USRECQ == 1
replace recession = r(min) if USRECQ == 0

local min = r(min)

****************************************************
* 8. Plot: recession shading + rho (LHS) + inflation (RHS)
****************************************************
set scheme s1color

twoway ///
    (area recession qdate, color(gs14) base(`min')) ///
    (line  rho       qdate, lcolor(blue) yaxis(1)) ///
    (line  infl_20q   qdate, lcolor(red)  yaxis(2)), ///
    xtitle("") ///
    ytitle("Rolling correlation of CF band-pass GDP and productivity", axis(1)) ///
    ytitle("Inflation (20q rolling avg, annualized q/q, %)", axis(2)) ///
    title("Rolling correlation with NBER recession shading") ///
    subtitle("CF filter (6–32q), 20-quarter rolling window; inflation on RHS axis") ///
    tlabel(, format(%tqCCYY)) ///
    legend(order(2 "Rolling corr (rho)" 3 "Inflation (20q avg, rhs)") pos(6) ring(0))
