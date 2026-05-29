clear all
set more off

****************************************************
* 1) Import QUARTERLY series (recession, productivity)
****************************************************
import fred USRECQ OPHNFB, clear

gen qdate = qofd(daten)
format qdate %tq
collapse (mean) USRECQ OPHNFB, by(qdate)
tsset qdate, quarterly

tempfile qdata
save `qdata', replace

****************************************************
* 2) Import MONTHLY CPS reason-for-unemployment + employment -> quarterly
*    CPS A-11, seasonally adjusted "Unemployment Level - ..."
****************************************************
import fred ///
    LNS13023621 /// Unemployment Level - Job Losers
    LNS13023705 /// Unemployment Level - Job Leavers
    LNS13023557 /// Unemployment Level - Reentrants to Labor Force
    LNS13023569 /// Unemployment Level - New Entrants
    CE16OV, clear   /// Employment level

rename LNS13023621 job_losers
rename LNS13023705 job_leavers
rename LNS13023557 reentrants
rename LNS13023569 new_entrants
rename CE16OV emp

* CPS proxies
gen sep  = job_losers
gen hire = job_leavers + reentrants + new_entrants

gen qdate = qofd(daten)
format qdate %tq

* Quarterly averages of monthly series
collapse (mean) sep hire emp, by(qdate)
tsset qdate, quarterly

* Rates: flow_t / employment_{t-1}
gen sep_rate  = sep  / L.emp
gen hire_rate = hire / L.emp

label var sep_rate  "Separation rate"
label var hire_rate "Hiring rate"

tempfile m2q
save `m2q', replace

****************************************************
* 3) Merge quarterly + monthly-to-quarterly
****************************************************
use `qdata', clear
merge 1:1 qdate using `m2q', nogen

* optional sample start
keep if qdate >= yq(1950,1)

****************************************************
* 4) Identify recession episodes and define peak/trough
****************************************************
sort qdate
gen rec = (USRECQ==1)
gen rec_start = rec==1 & L.rec==0
gen rec_end   = rec==1 & F.rec==0

* Episode id: increments at recession start (on the first recession quarter)
gen rec_id = sum(rec_start)

* Create an episode id that ALSO tags the peak quarter (t-1) with the same id
gen ep_id = rec_id
replace ep_id = F.rec_id if rec==0 & F.rec==1   // quarter immediately before recession start

* Episode start/end quarters (based on recession quarters only)
sort ep_id qdate
by ep_id: egen start_q = min(cond(rec==1, qdate, .))
by ep_id: egen end_q   = max(cond(rec==1, qdate, .))

* Peak quarter is quarter before start
gen peak_q = start_q - 1

****************************************************
* 5) Peak and trough values (computed within ep_id)
****************************************************
by ep_id: egen peak_sep_rate    = max(cond(qdate==peak_q, sep_rate, .))
by ep_id: egen trough_sep_rate  = max(cond(qdate==end_q,  sep_rate, .))

by ep_id: egen peak_hire_rate   = max(cond(qdate==peak_q, hire_rate, .))
by ep_id: egen trough_hire_rate = max(cond(qdate==end_q,  hire_rate, .))

by ep_id: egen peak_prod        = max(cond(qdate==peak_q, OPHNFB, .))
by ep_id: egen trough_prod      = max(cond(qdate==end_q,  OPHNFB, .))

****************************************************
* 6) Peak-to-trough changes
****************************************************
gen d_sep_rate_pp  = 100*(trough_sep_rate  - peak_sep_rate)
gen d_hire_rate_pp = 100*(trough_hire_rate - peak_hire_rate)
gen d_prod_pct     = 100*(ln(trough_prod) - ln(peak_prod))

****************************************************
* 7) Recession-level dataset (one row per recession)
****************************************************
preserve

* Keep only recession trough quarter (one obs per episode)
keep if ep_id>0 & qdate==end_q

keep ep_id peak_q start_q end_q d_sep_rate_pp d_hire_rate_pp d_prod_pct

* Drop incomplete episodes
drop if missing(d_sep_rate_pp, d_hire_rate_pp, d_prod_pct)

format peak_q start_q end_q %tq

tempfile rec_table
save `rec_table', replace
restore

****************************************************
* 8) ONE GRAPH: raw peak-to-trough changes
****************************************************
use `rec_table', clear

gen t = peak_q
format t %tq

label var d_sep_rate_pp  "Separation rate"
label var d_hire_rate_pp "Hiring rate"
label var d_prod_pct     "Productivity"

set scheme s1color

twoway ///
    (connected d_sep_rate_pp  t, msymbol(O)) ///
    (connected d_prod_pct     t, msymbol(S)), ///
    xtitle("") ///
    ytitle("Peak-to-trough change") ///
    title("Peak-to-trough changes over recessions") ///
    subtitle("Separation and hiring rates in percentage points; productivity in percent") ///
    tlabel(, format(%tqCCYY)) ///
    legend(order(1 "Separation rate (pp)" 2 "Productivity (%)") pos(10) ring(0))
