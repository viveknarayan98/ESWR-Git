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
* 2) Import MONTHLY CPS reason-for-unemployment + wages -> quarterly
*    CPS A-11, seasonally adjusted "Unemployment Level - ..."
****************************************************
import fred ///
    LNS13023621 /// Unemployment Level - Job Losers
    LNS13023705 /// Unemployment Level - Job Leavers
    LNS13023557 /// Unemployment Level - Reentrants to Labor Force
    LNS13023569 /// Unemployment Level - New Entrants
    CES0500000003, clear

rename LNS13023621 job_losers
rename LNS13023705 job_leavers
rename LNS13023557 reentrants
rename LNS13023569 new_entrants
rename CES0500000003 wage

* CPS proxies
gen sep  = job_losers
gen hire = job_leavers + reentrants + new_entrants

gen qdate = qofd(daten)
format qdate %tq

* Quarterly averages of monthly series
collapse (mean) sep hire wage, by(qdate)
tsset qdate, quarterly

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
*    peak_q = quarter before recession starts
*    trough = last recession quarter
****************************************************
sort qdate
gen rec = (USRECQ==1)
gen rec_start = rec==1 & L.rec==0
gen rec_end   = rec==1 & F.rec==0
gen rec_id = sum(rec_start)

sort rec_id qdate
by rec_id: egen start_q = min(cond(rec==1, qdate, .))
by rec_id: egen end_q   = max(cond(rec==1, qdate, .))
gen peak_q = start_q - 1

****************************************************
* 5) Peak and trough values
****************************************************
by rec_id: egen peak_sep    = max(cond(qdate==peak_q, sep, .))
by rec_id: egen trough_sep  = max(cond(qdate==end_q,  sep, .))

by rec_id: egen peak_hire   = max(cond(qdate==peak_q, hire, .))
by rec_id: egen trough_hire = max(cond(qdate==end_q,  hire, .))

by rec_id: egen peak_wage   = max(cond(qdate==peak_q, wage, .))
by rec_id: egen trough_wage = max(cond(qdate==end_q,  wage, .))

by rec_id: egen peak_prod   = max(cond(qdate==peak_q, OPHNFB, .))
by rec_id: egen trough_prod = max(cond(qdate==end_q,  OPHNFB, .))

****************************************************
* 6) Sensitivities (peak-to-trough log changes, %)
****************************************************
gen d_sep_pct  = 100*(ln(trough_sep)  - ln(peak_sep))
gen d_hire_pct = 100*(ln(trough_hire) - ln(peak_hire))
gen d_wage_pct = 100*(ln(trough_wage) - ln(peak_wage))
gen d_prod_pct = 100*(ln(trough_prod) - ln(peak_prod))

****************************************************
* 7) Recession-level dataset (one row per recession) + drop incomplete
****************************************************
preserve
keep if rec_id>0 & qdate==end_q

keep rec_id peak_q start_q end_q d_sep_pct d_hire_pct d_wage_pct d_prod_pct
drop if missing(d_sep_pct, d_hire_pct, d_wage_pct, d_prod_pct)

format peak_q start_q end_q %tq
tempfile rec_table
save `rec_table', replace
restore

****************************************************
* 8) ONE GRAPH: standardized sensitivities (z-scores)
****************************************************
use `rec_table', clear

gen t = peak_q
format t %tq

foreach v in d_sep_pct d_hire_pct d_wage_pct d_prod_pct {
    egen z_`v' = std(`v')
}

label var z_d_sep_pct  "Separations (CPS job losers)"
label var z_d_hire_pct "Hiring (CPS leavers+reentrants+entrants)"
label var z_d_wage_pct "Wages (AHE)"
label var z_d_prod_pct "Productivity (OPHNFB)"

set scheme s1color

twoway ///
    (connected z_d_sep_pct  t, msymbol(O)) ///
    (connected z_d_hire_pct t, msymbol(D)) ///
    (connected z_d_wage_pct t, msymbol(T)) ///
    (connected z_d_prod_pct t, msymbol(S)), ///
    xtitle("") ///
    ytitle("Standardized peak-to-trough response (z-score)") ///
    title("Sensitivity from cycle peak to recession trough") ///
    subtitle("CPS reasons for unemployment + wages + productivity") ///
    tlabel(, format(%tqCCYY)) ///
    legend(order(1 "Separations" 2 "Hiring" 3 "Wages" 4 "Productivity") pos(6) ring(0))
