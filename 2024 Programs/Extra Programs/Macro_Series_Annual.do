*******************************************************
* FRED -> annual dataset, 1979–2024
* - Annual frequency output
* - Monthly/quarterly series are converted to annual averages
*******************************************************

clear all
set more off

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Programs/ESWR-Git/Data/Clean"


* 0) Set your FRED API key (optional to store permanently)
set fredkey "86ca2054830db99b418a9a75dbe6000e", permanently

* 1) Pull the raw series (mixed frequencies)
import fred ///
    A939RX0Q048SBEA /// Real GDP per capita (quarterly) -> "Real output per person"
    OPHNFB          /// Output per hour (quarterly)     -> "Real output per hour"
    GDPCA           /// Real GDP (annual)              -> for GDP growth
    PCECCA          /// Real PCE (annual)              -> for real consumption growth
    GPDICA          /// Real gross private domestic investment (annual) -> "Fix private investment"
    COMPRNFB        /// Real compensation per hour (quarterly)
    A191RD3A086NBEA /// GDP deflator (annual)          -> for GDP deflator inflation
    DPCERD3A086NBEA /// PCE deflator (annual)          -> for PCE inflation
    FEDFUNDS        /// Federal funds rate (monthly)   -> annual average
    , clear

* 2) Create year and keep 1979–2024 (inclusive)

gen int year = year(daten)
keep if inrange(year, 1979, 2024)

* 3) Collapse to annual frequency
*    - For monthly/quarterly series: annual mean (annual average)
*    - For annual series: mean of the single annual observation
collapse (mean) ///
    real_output_per_person = A939RX0Q048SBEA ///
    real_output_per_hour   = OPHNFB ///
    real_comp_per_hour     = COMPRNFB ///
    fedfunds               = FEDFUNDS ///
    rgdp                   = GDPCA ///
    rpce                   = PCECCA ///
    rfixprivinv            = GPDICA ///
    gdp_deflator           = A191RD3A086NBEA ///
    pce_deflator           = DPCERD3A086NBEA ///
    , by(year)

* 4) Time-series setup
tsset year, yearly

* 5) Construct the "growth/inflation" series you asked for (annual, from annual levels)
gen gdp_growth        = 100 * (ln(rgdp)         - ln(L.rgdp))
gen cons_growth       = 100 * (ln(rpce)         - ln(L.rpce))
gen gdpdef_inflation  = 100 * (ln(gdp_deflator) - ln(L.gdp_deflator))
gen pce_inflation     = 100 * (ln(pce_deflator) - ln(L.pce_deflator))

* 6) Keep exactly what you asked for (annual, 1979–2024)
keep year ///
    real_output_per_person ///
    real_output_per_hour ///
    gdp_growth ///
    cons_growth ///
    rfixprivinv ///
    real_comp_per_hour ///
    gdpdef_inflation ///
    pce_inflation ///
    fedfunds

order year ///
    real_output_per_person real_output_per_hour ///
    gdp_growth cons_growth ///
    rfixprivinv real_comp_per_hour ///
    gdpdef_inflation pce_inflation ///
    fedfunds

* 7) Labels (optional but helpful)
label var real_output_per_person "Real output per person (annual avg of quarterly real GDP per capita)"
label var real_output_per_hour   "Real output per hour (annual avg of quarterly OPHNFB)"
label var gdp_growth             "GDP growth (annual, 100*Δln real GDP)"
label var cons_growth            "Real consumption growth (annual, 100*Δln real PCE)"
label var rfixprivinv            "Fixed private investment (real gross private domestic investment, annual level)"
label var real_comp_per_hour     "Real compensation per hour (annual avg of quarterly COMPRNFB)"
label var gdpdef_inflation       "GDP deflator inflation (annual, 100*Δln deflator)"
label var pce_inflation          "PCE inflation (annual, 100*Δln PCE deflator)"
label var fedfunds               "Federal funds rate (annual average of monthly FEDFUNDS)"

* 8) Sanity check
summ

* Optional saves:
save "fred_annual_1979_2024.dta", replace
* export delimited using "fred_annual_1979_2024.csv", replace

*******************************************************
* End
*******************************************************

