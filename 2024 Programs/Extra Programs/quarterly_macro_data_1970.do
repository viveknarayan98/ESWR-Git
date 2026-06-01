*******************************************************
* Quarterly macro dataset from FRED
* Sample: 1979q1–2024q4
*******************************************************

clear all
set more off

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Programs/ESWR-Git/Data/Clean"

* FRED API key
set fredkey "86ca2054830db99b418a9a75dbe6000e", permanently

*******************************************************
* Import quarterly + monthly series
*******************************************************
import fred ///
    A939RX0Q048SBEA /// real output per capita
    A796RX0Q048SBEA /// real nondurable consumption per capita
    FPI             /// real private fixed investment
    PCEDGC96        /// real durable consumption expenditures
    CNP16OV         /// civilian noninstitutional population (monthly)
    JTSJOR          /// vacancy rate (job openings rate, monthly)
    JTSTSR          /// separation rate (monthly)
    JTSQUR          /// quit rate (monthly)
    FEDFUNDS        /// federal funds rate (monthly)
    PCECTPI         /// PCE price index (quarterly)
    CIVPART         /// labor force participation rate (monthly)
    , clear

*******************************************************
* Create quarterly date
*******************************************************
gen qdate = qofd(daten)
format qdate %tq

*******************************************************
* Restrict sample
*******************************************************
keep if inrange(qdate, yq(1970,1), yq(2024,4))

*******************************************************
* Collapse monthly -> quarterly
* (quarterly series are unchanged by mean collapse)
*******************************************************
collapse (mean) ///
    y_pc            = A939RX0Q048SBEA ///
    c_nd_pc         = A796RX0Q048SBEA ///
    fixed_inv_real  = FPIC1 ///
    dur_cons_real   = PCEDGC96 ///
    pop             = CNP16OV ///
    vacancy_rate    = JTSJOR ///
    sep_rate        = JTSTSR ///
    quit_rate       = JTSQUR ///
    fedfunds        = FEDFUNDS ///
    pcepi           = PCECTPI ///
    lfp_rate        = CIVPART ///
    , by(qdate)

*******************************************************
* Time-series declaration
*******************************************************
tsset qdate, quarterly
rename qdate time

*******************************************************
* Construct investment per capita
* I = fixed private investment + durable consumption
*
* Note: because you only need Delta(log(I)),
* the population scaling constant does not matter.
*******************************************************
gen i_pc = (fixed_inv_real + dur_cons_real) / pop

*******************************************************
* Growth rates and inflation
*******************************************************
gen dlog_y = 100 * (ln(y_pc)    - ln(L.y_pc))
gen dlog_c = 100 * (ln(c_nd_pc) - ln(L.c_nd_pc))
gen dlog_i = 100 * (ln(i_pc)    - ln(L.i_pc))

* Quarterly inflation, annualized
gen inflation = 400 * (ln(pcepi) - ln(L.pcepi))

* Ex post real federal funds rate
gen real_funds_rate = fedfunds - inflation

*******************************************************
* Optional labels
*******************************************************
label var y_pc             "Real output per capita"
label var c_nd_pc          "Real nondurable consumption per capita"
label var i_pc             "Real investment per capita (fixed private + durables)"
label var dlog_y           "Quarterly log growth of output per capita"
label var dlog_c           "Quarterly log growth of nondurable consumption per capita"
label var dlog_i           "Quarterly log growth of investment per capita"
label var vacancy_rate     "Vacancy rate"
label var sep_rate         "Separation rate"
label var quit_rate        "Quit rate"
label var fedfunds         "Federal funds rate"
label var inflation        "PCE inflation (annualized q/q log change)"
label var real_funds_rate  "Ex post real federal funds rate"
label var lfp_rate         "Labor force participation rate"


rename time qdate 
drop sep_rate
merge 1:1 qdate using quarterly_macro_data


*******************************************************
* Optional: save
*******************************************************
save "quarterly_macro_fred_1970q1_2024q4.dta", replace


