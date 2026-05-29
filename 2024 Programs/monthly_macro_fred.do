*******************************************************
* Monthly macro dataset from FRED
* Sample: 1970m1 - 2024m12
*
* All variables stored at MONTHLY frequency.
* Quarterly series are forward-filled so the same value
* appears in all 3 months of the quarter.
*
* Per-labor-force (CLF16OV) normalization replaces
* per-capita normalization for the requested aggregates.
*******************************************************
clear all
set more off
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Programs/ESWR-Git/Data/Clean"

use fullcps, clear

sort cpsidp time

tsset cpsidp time
tsset cpsidp time

gen awchange = s12.lnwage
gen wchange0 = 0 if awchange!=.
replace wchange0 = 1 if wchange0 == 0 & abs(awchange)<=0.005

gen wchangep = 0 if awchange!=.
replace wchangep = 1 if wchangep==0 & awchange>0.005

gen wchangen = 0 if awchange!=.
replace wchangen = 1 if wchangen==0 & awchange<-0.005


gen EU        = 0 if l_status!=. & L.l_status==1
gen EN 	      = EU
replace EU    = 1 if EU==0 & l_status==2
replace EN    = 1 if EN==0 & l_status==3

gen EE=1 if   l_status==1 & l.l_status==1

gen UE        = 0 if l_status!=. & L.l_status==2
gen NE 	      = 0 if l_status!=. & L.l_status==3
replace UE    = 1 if UE==0 & l_status==1
replace NE    = 1 if NE==0 & l_status==1

gen empdenom= 1 if l_status!=. & l.l_status==1

gen averageweight= (wtfinl + l.wtfinl)/2
gen averageweightoneyear= (wtfinl + l12.wtfinl)/2

rename time mdate

collapse(mean)EU (sum) wchange0 wchangep wchangen  [aw=averageweightoneyear], by (mdate)

gen frac_wc_0 = wchange0/(wchange0+wchangep+wchangen)
gen frac_wc_neg = wchangen/(wchange0+wchangen+wchangep)

drop w*

save monthly_sep_wchange, replace

* FRED API key
set fredkey "86ca2054830db99b418a9a75dbe6000e", permanently

*******************************************************
* Import series from FRED
* When mixed-frequency series are imported together, the
* dataset is at the highest (monthly) frequency. Quarterly
* observations sit in the first month of each quarter and
* are missing in the other two months -- we fill them in
* below.
*******************************************************
import fred ///
    GDPC1           /// real GDP, chained 2017$, quarterly LEVEL
    PCECC96         /// real personal consumption expenditures, QUARTERLY level
    FPI           /// real private fixed investment, quarterly level
    PCEDGC96        /// real durable consumption expenditures, quarterly level
    CLF16OV         /// civilian labor force, 16+, monthly LEVEL  (denominator)
    CNP16OV         /// civilian noninstitutional population (kept for reference)
    JTSJOR          /// JOLTS job openings RATE (V/LF), monthly, from 2000m12
    JTSJOL          /// JOLTS job openings LEVEL, monthly (kept for reference)
    UNRATE          /// civilian unemployment rate, monthly
    UNEMPLOY        /// number unemployed (level), monthly
    JTSTSL          /// JOLTS total separations level, monthly (kept for reference)
    FEDFUNDS        /// federal funds rate, monthly
    CPIAUCSL        /// CPI-U, all items, monthly
    PCEPILFE        /// core PCE price index, monthly
    COMPRNFB        /// real compensation per hour, nonfarm business, quarterly
    CIVPART         /// labor force participation rate, monthly
    , clear

*******************************************************
* Date setup -- keep monthly as the panel frequency
*******************************************************
gen mdate = mofd(daten)
format mdate %tm
gen qdate = qofd(daten)
format qdate %tq
order mdate qdate
sort mdate

* Restrict sample
keep if mdate >= ym(1970,1) & mdate <= ym(2024,12)

*******************************************************
* Forward-fill quarterly series within each quarter so
* the same value appears in months 1, 2, 3 of the quarter.
*******************************************************
local qvars GDPC1 PCECC96 FPI PCEDGC96 COMPRNFB
foreach v of local qvars {
    bysort qdate (mdate): replace `v' = `v'[1] if missing(`v')
}

*******************************************************
* Per-labor-force aggregates (CLF16OV is in thousands;
* the GDP/C/I levels are in billions of chained dollars,
* so the ratio is in $millions per worker. The scale is
* irrelevant for log differences.)
*******************************************************
gen y_lf  = GDPC1                       / CLF16OV   // GDP / LF (Q)
gen c_lf  = PCECC96                     / CLF16OV   // C / LF (Q, ffilled)
gen i_lf  = FPI         / CLF16OV   // (Ifix + Cdur) / LF (Q)

*******************************************************
* Vacancy / Labor force
*  - JOLTS JTSJOR (job openings RATE = V/LF) from 2000m12
*  - Barnichon (2010) composite HWI, V/LF column, before.
*
* HWIURATIO is no longer on FRED, so Barnichon's data is
* read from a local .xlsx download of his Google Sheet:
*   https://docs.google.com/spreadsheets/d/1fkMinSHkjTL99-bLZYFldQ8rHtgh8lxd
*
* Per Barnichon's note, column C is already in the same
* units as the JOLTS job-openings rate -- so no rescaling.
*
* REQUIRED: save the Google Sheet as a file named
*   barnichon_hwi.xlsx
* in ${mypath}/Programs/ESWR-Git/Data/Clean  (cwd).
*
* Sheet layout (per Barnichon's download):
*   data starts at cell A8 (no header row above that)
*   col A = year as decimal  (1951.00 = Jan 1951,
*                             1951.08 = Feb 1951, ...,
*                             +1/12 per month)
*   col B = HWI level
*   col C = V/LF -- already matched to JOLTS
* (Row 596 = Dec 1999 per user's copy.)
*******************************************************
preserve
    import excel using "barnichon_hwi.xlsx", cellrange(A8) clear

    * After import, the three columns are named A, B, C
    rename A yr_frac
    rename C barn_v_lf

    destring yr_frac  , replace force
    destring barn_v_lf, replace force

    drop if missing(yr_frac) | missing(barn_v_lf)

    * Decimal year -> Stata monthly date (ym(1960,1) == 0)
    gen mdate = round((yr_frac - 1960) * 12)
    format mdate %tm

    keep mdate barn_v_lf
    tempfile barn
    save `barn'
restore

merge 1:1 mdate using `barn', nogen keep(master match)

* Splice: Barnichon pre-JOLTS, JTSJOR from 2000m12 onward
gen vacancy_lf = barn_v_lf                  if mdate <  ym(2000,12)
replace vacancy_lf = JTSJOR                  if mdate >= ym(2000,12) & !missing(JTSJOR)

*******************************************************
* Inflation series (annualized, m/m log differences)
*******************************************************
tsset mdate, monthly

gen cpi_inflation       = 1200 * (ln(CPIAUCSL) - ln(L.CPIAUCSL))
gen core_pce_inflation  = 1200 * (ln(PCEPILFE) - ln(L.PCEPILFE))

*******************************************************
* Growth rates of GDP, C, I per labor force participant
* All three are quarterly series on the monthly grid,
* so we use a 3-month log diff (q/q growth, constant
* across the 3 months of the quarter).
*******************************************************
gen dlog_y = 100 * (ln(y_lf) - ln(L3.y_lf))   // q/q
gen dlog_c = 100 * (ln(c_lf) - ln(L3.c_lf))   // q/q
gen dlog_i = 100 * (ln(i_lf) - ln(L3.i_lf))   // q/q

*******************************************************
* Real federal funds rate (monthly, ex post, using core PCE)
*******************************************************
gen real_funds_rate = FEDFUNDS - core_pce_inflation

*******************************************************
* Tidy / rename for downstream use
*******************************************************
rename FEDFUNDS  fedfunds
rename CPIAUCSL  cpi
rename PCEPILFE  core_pce
rename COMPRNFB  real_comp_hour
rename CLF16OV   labor_force
rename CIVPART   lfp_rate
rename UNRATE    unrate
rename JTSJOL    vacancy_level
rename JTSJOR    jolts_v_rate
rename JTSTSL    sep_level
label var jolts_v_rate      "JOLTS job openings rate (V/LF), 2000m12+"
label var barn_v_lf         "Barnichon (2010) V/LF index, matched to JOLTS"
label var vacancy_lf        "Vacancy / Labor force (Barnichon pre-2000m12, JOLTS after)"

label var y_lf              "Real GDP per labor force participant (Q, ffilled)"
label var c_lf              "Real PCE per labor force participant (Q, ffilled)"
label var i_lf              "Real (Ifix+Cdur) per labor force participant (Q, ffilled)"
label var dlog_y            "Q/Q log growth, real GDP per LF (x100)"
label var dlog_c            "Q/Q log growth, real C per LF (x100)"
label var dlog_i            "Q/Q log growth, real I per LF (x100)"
label var vacancy_lf        "Vacancy / Labor force (Barnichon spliced w/ JOLTS)"
label var cpi_inflation     "CPI inflation, annualized m/m log change"
label var core_pce_inflation "Core PCE inflation, annualized m/m log change"
label var fedfunds          "Federal funds rate (monthly)"
label var real_funds_rate   "Ex post real FFR (FFR - core PCE infl)"
label var real_comp_hour    "Real compensation per hour, nonfarm business (Q, ffilled)"
label var labor_force       "Civilian labor force, 16+ (CLF16OV)"
label var lfp_rate          "Labor force participation rate"

keep mdate qdate ///
     y_lf c_lf i_lf dlog_y dlog_c dlog_i ///
     vacancy_lf barn_v_lf jolts_v_rate ///
     cpi_inflation core_pce_inflation ///
     fedfunds real_funds_rate real_comp_hour ///
     labor_force lfp_rate unrate vacancy_level sep_level

order mdate qdate

*******************************************************
* Merge with monthly file containing
*   - EU separations
*   - fraction of 0 wage changes
*   - fraction of negative wage changes
* (kept at MONTHLY frequency; no quarterly collapse)
*
* Replace `monthly_macro_data` below with the actual
* filename of your monthly CPS-derived dataset. It must
* be keyed on `mdate` (Stata monthly date).
*******************************************************

merge 1:1 mdate using monthly_sep_wchange, nogen
drop _merge

*******************************************************
* Save
*******************************************************
tsset mdate, monthly
save "monthly_macro_fred_1970m1_2024m12.dta", replace
