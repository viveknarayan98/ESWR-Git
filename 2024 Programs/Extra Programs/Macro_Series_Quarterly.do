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

* Import quarterly + monthly series
import fred ///
    A939RX0Q048SBEA /// real GDP per capita
    OPHNFB          /// output per hour
    GDPC1           /// real GDP
    PCECC96         /// real PCE
    GPDIC1          /// real gross private domestic investment
    COMPRNFB        /// real compensation per hour
    GDPDEF          /// GDP deflator
    DPCERD3Q086SBEA /// PCE deflator
    FEDFUNDS        /// federal funds rate (monthly)
    , clear

* Create quarterly date
gen qdate = qofd(daten)
format qdate %tq

* Restrict sample
keep if inrange(qdate, yq(1979,1), yq(2024,4))

* Collapse monthly -> quarterly (quarterly series unaffected)
collapse (mean) ///
    real_output_per_person = A939RX0Q048SBEA ///
    real_output_per_hour   = OPHNFB ///
    rgdp                   = GDPC1 ///
    rpce                   = PCECC96 ///
    rprivinv               = GPDIC1 ///
    real_comp_per_hour     = COMPRNFB ///
    gdp_deflator           = GDPDEF ///
    pce_deflator           = DPCERD3Q086SBEA ///
    fedfunds               = FEDFUNDS ///
    , by(qdate)

* Time-series declaration
tsset qdate, quarterly
rename qdate time

*******************************************************
* OPTIONAL: growth and inflation (quarterly)
*******************************************************
gen gdp_growth_q   = 100*(ln(rgdp) - ln(L.rgdp))
gen cons_growth_q  = 100*(ln(rpce) - ln(L.rpce))
gen gdp_infl_q     = 100*(ln(gdp_deflator) - ln(L.gdp_deflator))
gen pce_infl_q     = 100*(ln(pce_deflator) - ln(L.pce_deflator))

*******************************************************
* Save
*******************************************************
save "fred_quarterly_1979q1_2024q4.dta", replace
* export delimited using "fred_quarterly_1979q1_2024q4.csv", replace
*******************************************************
* End
*******************************************************
