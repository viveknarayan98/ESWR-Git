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

****************************************************
* 4) Identify recession peaks
*    Peak = quarter before recession starts
****************************************************
gen rec = (USRECQ==1)
gen rec_start = rec==1 & L.rec==0

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

****************************************************
* 5) Create event-time panel:
*    for each recession episode, keep peak through +8 quarters
****************************************************
gen one = 1

tempfile master
save `master', replace

use `peaks', clear
gen one = 1

joinby one using `master'
drop one

gen h = qdate - peak_q
keep if h >= 0 & h <= 8

format qdate peak_q start_q %tq
sort ep_id h

****************************************************
* 6) Get peak values within each recession window
****************************************************
by ep_id: egen peak_sep_rate  = max(cond(h==0, sep_rate, .))
by ep_id: egen peak_hire_rate = max(cond(h==0, hire_rate, .))
by ep_id: egen peak_prod      = max(cond(h==0, OPHNFB, .))

****************************************************
* 7) Changes relative to peak
****************************************************
gen d_sep_rate_pp  = 100*(sep_rate  - peak_sep_rate)
gen d_hire_rate_pp = 100*(hire_rate - peak_hire_rate)
gen d_prod_pct     = 100*(ln(OPHNFB) - ln(peak_prod))

label var d_sep_rate_pp  "Change in separation rate from peak (pp)"
label var d_hire_rate_pp "Change in hiring rate from peak (pp)"
label var d_prod_pct     "Change in productivity from peak (%)"

****************************************************
* 8) Make readable recession labels
****************************************************
gen peak_lbl = string(year(dofq(peak_q))) + "q" + string(quarter(dofq(peak_q)))

****************************************************
* 9) Plot separation-rate response: one line per recession
****************************************************
levelsof ep_id, local(ids)

local plot_sep
local leg_sep
local i = 1

foreach id of local ids {
    quietly summarize peak_q if ep_id==`id', meanonly
    local pk = r(mean)
    local lbl = string(year(dofq(`pk'))) + "q" + string(quarter(dofq(`pk')))

    local plot_sep `plot_sep' ///
        (connected d_sep_rate_pp h if ep_id==`id', sort msymbol(none))

    local leg_sep `leg_sep' `i' "`lbl'"
    local ++i
}

set scheme s1color

twoway `plot_sep', ///
    xtitle("Quarters since peak") ///
    ytitle("Change in separation rate from peak (pp)") ///
    title("Separation-rate response over recessions") ///
    subtitle("One line per recession") ///
    xlabel(0(1)8) ///
    legend(order(`leg_sep') cols(2) pos(3) ring(1) size(vsmall))

****************************************************
* 10) Plot productivity response: one line per recession
****************************************************
levelsof ep_id, local(ids)

local plot_prod
local leg_prod
local i = 1

foreach id of local ids {
    quietly summarize peak_q if ep_id==`id', meanonly
    local pk = r(mean)
    local lbl = string(year(dofq(`pk'))) + "q" + string(quarter(dofq(`pk')))

    local plot_prod `plot_prod' ///
        (connected d_prod_pct h if ep_id==`id', sort msymbol(none))

    local leg_prod `leg_prod' `i' "`lbl'"
    local ++i
}

twoway `plot_prod', ///
    xtitle("Quarters since peak") ///
    ytitle("Change in productivity from peak (%)") ///
    title("Productivity response over recessions") ///
    subtitle("One line per recession") ///
    xlabel(0(1)8) ///
    legend(order(`leg_prod') cols(2) pos(6) ring(1) size(vsmall))
