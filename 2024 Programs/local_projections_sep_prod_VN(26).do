global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"

***MP Shocks
import delimited "${mypath}/Data/Raw/Macro Data Files/shocks_fed_jk_m.csv", clear

*Generate date vars

gen datem= ym(year, month)
format datem %tm

tsset datem

*Cumulative monetary policy shocks
gen mp_cum = sum(mp_median)

gen quarter= ceil(month/3)
gen qdate= yq(year, quarter)
format qdate %tq
 

*Collapse by quarter 
collapse (mean) mp_cum, by(qdate)
tsset qdate

*
gen mpshock = d.mp_cum
drop mp_cum
cd "${mypath}/Data/Clean"

save mp_shock_q, replace

*Import separations and productivity from FRED

import fred JTS1000HIR JTS1000QUR JTS1000LDR JTS1000OSR JTS1000TSR OPHNFB UNRATE FEDFUNDS PCEPI GDPC1, aggregate(quarterly) clear

rename JTS1000HIR hires_rate
rename JTS1000QUR quits_rate
rename JTS1000LDR layoffs_discharges_rate
rename JTS1000OSR other_separations_rate
rename JTS1000TSR total_separations_rate
rename UNRATE unemployment
rename FEDFUNDS fed_funds
rename OPHNFB output_per_hour


gen qdate = qofd(daten)
format qdate %tq
tsset qdate

gen inflation= D.PCEPI/L.PCEPI
gen gdp_growth= D.GDPC1/L.GDPC1 

drop daten datestr GDPC1 PCEPI

merge 1:1 qdate using mp_shock_q

keep if _merge==3
drop _merge

keep if total_separations_rate!=.
 
*To create the left-hand side at each horizon
 
***Create variable horizons
local hmax = 8
local basevars ""

foreach x of varlist *_rate output_per_hour{
	local basevars `basevars' `x'
              forvalues h = 0/`hmax' {
                             gen `x'`h' = f`h'.`x' - l.`x'          
              }
}
unab variables : hires* quits* layoffs* other* total* output*

gen year    = year(dofq(qdate))
gen quarter = quarter(dofq(qdate))
gen coviddummy = (year==2020 & inrange(quarter, 2, 4))
rename qdate time

*local variables hires* quits* layoffs* other* total* output*

***Execute and store LPs
foreach x of local basevars{
eststo clear
cap drop b0 u0 d0 u090 d090 b1 u1 d1 u190 d190 Ms Zero
gen Ms   = _n-1  if _n<=`hmax'+1
gen Zero = 0     if _n<=`hmax'+1
gen b0   = 0
gen u0   = 0
gen d0   = 0
gen u090 = 0
gen d090 = 0
gen b1   = 0
gen u1   = 0
gen d1   = 0
gen u190 = 0
gen d190 = 0
                            
forv h=0/`hmax' {
 
 
reg `x'`h' mpshock L(1/3).`x' L(1/3).inflation L(1/3).unemployment L(1/3).fed_funds L(1/3).gdp_growth time coviddummy
 
 
replace b0   = (_b[mpshock])                      if _n == `h'+1
replace u0   = (_b[mpshock] + 1.00* _se[mpshock]  )   if _n == `h'+1 
replace d0   = (_b[mpshock] - 1.00* _se[mpshock]  )   if _n == `h'+1
replace u090 = (_b[mpshock] + 1.645* _se[mpshock]  )   if _n == `h'+1 
replace d090 = (_b[mpshock] - 1.645* _se[mpshock]  )   if _n == `h'+1

eststo
nois esttab , se nocons keep(mpshock)
}
twoway (rarea u090 d090 Ms, color(gs14) lwidth(none)) ///
       (rarea u0   d0   Ms, color(gs10) lwidth(none)) ///
       (line   b0        Ms, lcolor(navy) lwidth(medthick)) ///
       (line   Zero      Ms, lcolor(red) lpattern(dash)), ///
       ytitle("Response of `x'") xtitle("Horizon (quarters)") ///
       legend(off) title("`x'") name(irf_`x', replace)

graph export "${mypath}/Data/Clean/Output/irf_`x'.png", replace width(1200)
}

