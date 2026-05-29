clear all

****************************************************
* 1. Import FRED data (GDP, productivity, recessions)
****************************************************
import fred GDPC1 OPHNFB USRECQ, clear

* Quarterly date
gen qdate = qofd(daten)
format qdate %tq
tsset qdate, quarterly

*keep if qdate >= yq(1970,1)

****************************************************
* 2. Log levels
****************************************************
gen lgdp = ln(GDPC1)
gen lop  = ln(OPHNFB)

****************************************************
* 3. HP-filter both series (lambda defaults to 1600 for quarterly)
*    c_lgdp and c_lop are the cyclical components
****************************************************
tsfilter hp c_lgdp = lgdp, trend(tr_lgdp)
tsfilter hp c_lop  = lop,  trend(tr_lop)

label var c_lgdp "Cyclical component of log GDP"
label var c_lop  "Cyclical component of log productivity"

drop if missing(c_lgdp, c_lop)

****************************************************
* 4. Prepare for rolling
****************************************************
gen obs = _n
tempfile base
save `base'

****************************************************
* 5. Rolling correlation of cyclical components
*    (10-quarter window)
****************************************************
rolling rho = r(rho), window(10) saving(hproll, replace): ///
    correlate c_lgdp c_lop

use hproll, clear

* Align rolling window index with original sample
* First rho corresponds to the 10th observation
gen obs = _n + 10 - 1

merge 1:1 obs using `base', keep(match) nogen

****************************************************
* 6. Rebuild qdate after merge (avoid any misalignment)
****************************************************
drop qdate
gen qdate = qofd(daten)
format qdate %tq
tsset qdate, quarterly

****************************************************
* 7. Restrict to observations where rho is defined
****************************************************
keep if rho < .

****************************************************
* 8. Build recession shading variable (Stata blog method)
****************************************************
* USRECQ = 1 in NBER recessions, 0 otherwise
summarize rho

* Recession shading series:
* - = max(rho) in recessions
* - = min(rho) in expansions
gen recession_shade = r(max) if USRECQ == 1
replace  recession_shade = r(min) if USRECQ == 0



* Store the minimum for the base() option
local min = r(min)

****************************************************
* 9. Plot: area (recession shading) + line (rolling correlation)
****************************************************
set scheme s1color

twoway ///
    (area recession_shade qdate, color(gs14) base(`min')) ///
    (line  rho            qdate, lcolor(blue) lwidth(medthick)), ///
    yline(0, lpattern(dash)) ///
    title("Rolling correlation of HP-filtered GDP and productivity") ///
    subtitle("HP cyclical components (λ = 1600), 10-quarter rolling window") ///
    xtitle("Quarter") ///
    ytitle("Correlation") ///
    tlabel(, format(%tqCCYY)) ///
    legend(order(2 "Rolling correlation" 1 "NBER recessions"))
