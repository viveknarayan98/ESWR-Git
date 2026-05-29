clear all
set more off

****************************************************
* 1) Import QUARTERLY series (recession, productivity, GDP)
****************************************************
import fred USRECQ OPHNFB GDPC1, clear
gen qdate = qofd(daten)
format qdate %tq
collapse (mean) USRECQ OPHNFB GDPC1, by(qdate)
tsset qdate, quarterly
tempfile qdata
save `qdata', replace

****************************************************
* 2) Import MONTHLY CPS reason-for-unemployment + employment -> quarterly
****************************************************
import fred ///
    LNS13023621 /// Job losers
    LNS13023705 /// Job leavers
    LNS13023557 /// Reentrants
    LNS13023569 /// New entrants
    CE16OV, clear   /// Employment

	
rename LNS13023621 job_losers
rename LNS13023705 job_leavers
rename LNS13023557 reentrants
rename LNS13023569 new_entrants
rename CE16OV emp

gen sep  = job_losers
gen hire = job_leavers + reentrants + new_entrants
gen qdate = qofd(daten)
format qdate %tq
collapse (mean) sep hire emp, by(qdate)
tsset qdate, quarterly
gen sep_rate  = sep  / L.emp
gen hire_rate = hire / L.emp
tempfile m2q
save `m2q', replace

****************************************************
* 3) Merge macro + CPS quarterly
****************************************************
use `qdata', clear
merge 1:1 qdate using `m2q', nogen
keep if qdate >= yq(1950,1)
tsset qdate, quarterly
sort qdate
keep if year(dofq(qdate)) >= 1970
tempfile master
save `master', replace

****************************************************
* 4) Identify recession peaks AND troughs, properly paired
*    Peak   = quarter before rec_start
*    Trough = first rec_end on or after start_q  (handles the
*             case where the sample begins mid-recession)
****************************************************
gen rec       = (USRECQ==1)
gen rec_start = rec==1 & L.rec==0
gen rec_end   = rec==1 & F.rec==0

* --- list of peaks (one row per rec_start) ---
preserve
    keep if rec_start==1
    gen ep_id   = _n
    gen peak_q  = qdate - 1
    gen start_q = qdate
    format peak_q start_q %tq
    keep ep_id peak_q start_q
    tempfile peaks
    save `peaks', replace
restore

* --- list of every rec_end in the sample (no ep_id yet) ---
preserve
    keep if rec_end==1
    gen trough_q = qdate
    format trough_q %tq
    keep trough_q
    tempfile troughs_raw
    save `troughs_raw', replace
restore

* --- pair each peak with its FIRST trough on/after start_q ---
use `peaks', clear
cross using `troughs_raw'
keep if trough_q >= start_q
bysort ep_id (trough_q): keep if _n==1
keep ep_id peak_q start_q trough_q
tempfile peaks_all
save `peaks_all', replace

****************************************************
* 5) Build event-time panel:
*    for each recession episode, keep peak through +12 quarters
*    (wider than before so the NBER trough is always in-window)
****************************************************
use `peaks_all', clear
gen one = 1
tempfile peaks_one
save `peaks_one', replace

use `master', clear
gen one = 1
joinby one using `peaks_one'
drop one
gen h = qdate - peak_q
keep if h >= 0 & h <= 12
format qdate peak_q start_q trough_q %tq
sort ep_id h

****************************************************
* 6) Values at peak and at trough for each episode
****************************************************
by ep_id: egen peak_sep_rate  = max(cond(h==0, sep_rate,  .))
by ep_id: egen peak_hire_rate = max(cond(h==0, hire_rate, .))
by ep_id: egen peak_prod      = max(cond(h==0, OPHNFB,    .))
by ep_id: egen gdp_peak       = max(cond(h==0, GDPC1,     .))
by ep_id: egen gdp_trough     = max(cond(qdate==trough_q, GDPC1, .))

* Peak-to-trough real GDP decline, in percent (positive number = bigger recession)
gen gdp_drop_pct = 100 * (gdp_peak - gdp_trough) / gdp_peak
label var gdp_drop_pct "Peak-to-trough real GDP decline (%)"

****************************************************
* 7) Changes from peak, then NORMALIZE by recession size
****************************************************
drop if year(dofq(start_q)) == 2001
gen d_sep_rate_pp  = 100*(sep_rate  - peak_sep_rate)
gen d_hire_rate_pp = 100*(hire_rate - peak_hire_rate)
gen d_prod_pct     = 100*(ln(OPHNFB) - ln(peak_prod))

* Per 1 percentage point of peak-to-trough GDP decline
gen d_sep_rate_norm  = d_sep_rate_pp  / gdp_drop_pct
gen d_hire_rate_norm = d_hire_rate_pp / gdp_drop_pct
gen d_prod_norm      = d_prod_pct     / gdp_drop_pct

label var d_sep_rate_norm  "Separation-rate change, per 1pp GDP drop"
label var d_hire_rate_norm "Hiring-rate change, per 1pp GDP drop"
label var d_prod_norm      "Productivity change, per 1pp GDP drop"

* Restrict to the original display horizon for the plots
keep if h <= 8

****************************************************
* 8) Readable recession labels including peak-to-trough GDP drop
****************************************************
gen peak_lbl = string(year(dofq(peak_q))) + "q" + string(quarter(dofq(peak_q)))

****************************************************
* 9) Plot NORMALIZED separation-rate response
****************************************************
levelsof ep_id, local(ids)
local plot_sep
local leg_sep
local i = 1
foreach id of local ids {
    quietly summarize peak_q if ep_id==`id', meanonly
    local pk = r(mean)
    quietly summarize gdp_drop_pct if ep_id==`id', meanonly
    local drop : display %3.1f r(mean)
    local drop = strtrim("`drop'")
    local lbl = string(year(dofq(`pk'))) + "q" + string(quarter(dofq(`pk'))) ///
                + " (-`drop'% GDP)"
    local plot_sep `plot_sep' ///
        (connected d_sep_rate_norm h if ep_id==`id', sort msymbol(none))
    local leg_sep `leg_sep' `i' "`lbl'"
    local ++i
}
set scheme s1color
twoway `plot_sep', ///
    xtitle("Quarters since peak") ///
    ytitle("Separation-rate change per 1pp of GDP decline") ///
    title("Separation-rate response, normalized by recession size") ///
    subtitle("Divided by peak-to-trough real GDP decline") ///
    xlabel(0(1)8) ///
    yline(0, lcolor(gs8) lpattern(dash)) ///
    legend(order(`leg_sep') cols(2) pos(6) ring(1) size(vsmall))

****************************************************
* 10) Plot NORMALIZED productivity response
****************************************************
levelsof ep_id, local(ids)
local plot_prod
local leg_prod
local i = 1
foreach id of local ids {
    quietly summarize peak_q if ep_id==`id', meanonly
    local pk = r(mean)
    quietly summarize gdp_drop_pct if ep_id==`id', meanonly
    local drop : display %3.1f r(mean)
    local drop = strtrim("`drop'")
    local lbl = string(year(dofq(`pk'))) + "q" + string(quarter(dofq(`pk'))) ///
                + " (-`drop'% GDP)"
    local plot_prod `plot_prod' ///
        (connected d_prod_norm h if ep_id==`id', sort msymbol(none))
    local leg_prod `leg_prod' `i' "`lbl'"
    local ++i
}
twoway `plot_prod', ///
    xtitle("Quarters since peak") ///
    ytitle("Productivity change per 1pp of GDP decline") ///
    title("Productivity response, normalized by recession size") ///
    subtitle("Divided by peak-to-trough real GDP decline") ///
    xlabel(0(1)8) ///
    yline(0, lcolor(gs8) lpattern(dash)) ///
    legend(order(`leg_prod') cols(2) pos(6) ring(1) size(vsmall))
