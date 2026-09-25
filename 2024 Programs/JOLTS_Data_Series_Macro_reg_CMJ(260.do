clear
cls

* Declare user
global user = "c"

* Global folder
if "$user"=="v" {
	global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"
}
if "$user"=="c" {
	global mypath "/mq/scratch/m1cxm05/ESWR"
}

cd "${mypath}/Data/Clean"

*Downloaded from https://data.bls.gov/PDQWeb/jt*

import excel "${mypath}/Data/Raw/Macro Data Files/JOLTS_data.xlsx", sheet("BLS Data Series") cellrange(A4:LM84) firstrow allstring clear

gen industrycode= substr(SeriesID, 4, 6)

merge m:1 industrycode using jt_industry

keep if _merge==3

gen data_series = substr(SeriesID, -3, 3)


* Step 1: rename MonYYYY vars to val1, val2, ..., val324
local i = 0
forvalues y = 2000/2026 {
    foreach mo in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec {
        local i = `i' + 1
        capture rename `mo'`y' val`i'
    }
}

* Step 2: reshape to long
reshape long val, i(SeriesID) j(monthnum)

* Step 3: convert monthnum (1..324) to a real Stata monthly date
gen date = ym(2000,1) + monthnum - 1
format date %tm

* (optional) drop the helper index
drop monthnum


destring val, replace

drop SeriesID industrycode _merge

reshape wide val, i(date industrydescription) j(data_series) string

label var valHIR "Hires"
label var valJOR "Job Openings"
label var valLDR "Layoff and discharges"
label var valOSR "Other Separations"
label var valQUR "Quits"

gen trimdescrip = substr(industrydescription, 1, 4)

gen qdate = qofd(dofm(date))
format qdate %tq

collapse (mean) valHIR valJOR valLDR valOSR valQUR, by(industrydescription trimdescrip qdate)

rename qdate time

*cd "${mypath}/Programs/ESWR-Git/Data/Clean"



*Connecting the descriptions to Line Codes

*Called private educational services in JOLTS and educational services in BEA


replace trimdescrip = "Educ" if trimdescrip=="Priv"
merge m:1 trimdescrip using Line_Code_Descrip

keep if _merge==3
drop _merge

*Connecting the JOLTS data to our quarterly macro data
merge 1:1 time trimdescrip using merged_cps_quarterly_jolts

keep if _merge==3

drop _merge

save JOLTS_macro_reg_series, replace
*Now execute lines 20-64 from Execute_Macro_Regression to get the results (note that you will have to change the LHS variable to something from JOLTS when executing the regression)


*Set panel and time vars
xtset LineCode time
 
*Create productivity and inflation measures


*gen prodh_i = GDP/thours
*gen lprod= log(prodh_i)
*gen lprice= log(price_i)
*gen wrigid = wchange0/(wchange0 + wchangen)

gen lrwage = log(wage/price_i)
gen lnwage = ln(wage)
gen lsep   = log(EU)
gen lhiresu = log(UE)
gen lhires = log(UE+NE)
gen lsep_a = log(EU+EN)
gen lprod4 = log(GDP/(thours))
gen lrwage_rig = lrwage*wrigid
gen lprod_rig = lprod*wrigid
gen dlrwage = d.lrwage
gen dlprod  = d.lprod
gen dlsep   = d.lsep
gen dlrwage_rig = d.lrwage_rig
gen dlprod_rig  = d.lprod_rig
gen dlrwage_rig2 = d.lrwage*L.wrigid
gen dlprod_rig2  = d.lprod*L.wrigid
gen DEN = EU+EN+EE

gen GDP_G = log(GDP) - log(L.GDP)

/*
if `quarterly'==0{
	save merged_cps_annual, replace
}
else{
	save merged_cps_quarterly, replace
}
*/


*Mean EMP is weight
egen double mean_EMP = mean(EmploymentCPS), by(LineCode)

*Run regression***

gen lsepr = log(EU/(EU+EN+EE))
gen lseprt = log((EU+EN)/(EU+EN+EE))

egen trend=group(time)
gen trend2 = trend^2
gen prodgrowth = d.lprod
gen inflation_lc = d.lprice

*reg F.valLDR c.trend##i.LineCode i.time  age education* nWhite male unionm unionc GDP_G lrwage lprod wrigid [iw=EmploymentCPS], robust 

*---------------- PROGRAMS FOR HORIZON-COEFFICIENT PLOTS ----------------*
global graphpath "/if/research-afe/joaquin/wage rigidity/Empirical programs"

capture program drop horizon_coefs
program define horizon_coefs, rclass
    syntax, depvar(string) rhs(string) wtvar(string) covars(string)
    tempname results
    matrix `results' = J(4, 2*wordcount("`covars'"), .)
    forvalues h = 1/4 {
        quietly reg F`h'.`depvar' `rhs' [iw=`wtvar'], robust
        local col = 1
        foreach v of local covars {
            matrix `results'[`h', `col']   = _b[`v']
            matrix `results'[`h', `col'+1] = _se[`v']
            local col = `col' + 2
        }
    }
    return matrix results = `results'
end

capture program drop plot_horizon_coef
program define plot_horizon_coef
    syntax, matname(string) col(integer) ytitle(string) title(string) filename(string)
    preserve
    clear
    set obs 4
    gen horizon = _n
    gen b  = .
    gen se = .
    forvalues h = 1/4 {
        replace b  = el(`matname', `h', `col')   if horizon==`h'
        replace se = el(`matname', `h', `col'+1) if horizon==`h'
    }
    gen ci_lo90 = b - 1.645*se
    gen ci_hi90 = b + 1.645*se

    twoway (rcap ci_lo90 ci_hi90 horizon, lcolor(gs8) lwidth(medium)) ///
           (connected b horizon, mcolor(navy) lcolor(navy) msymbol(circle) msize(medium)), ///
        xlabel(1 "t+1" 2 "t+2" 3 "t+3" 4 "t+4", noticks) ///
        xtitle("Forecast horizon (quarters ahead)") ///
        ytitle("`ytitle'") ///
        title("`title'") ///
        yline(0, lpattern(dash) lcolor(black)) ///
        legend(order(2 "Point estimate" 1 "90% CI") pos(6) rows(1)) ///
        graphregion(color(white)) plotregion(color(white)) scheme(s2color)

    graph export "${graphpath}/`filename'", replace width(2000)
    restore
end

local rhs_common "i.time c.trend##i.LineCode c.trend2##i.LineCode age education* nWhite male unionm unionc GDP_G"
local rhs_A "`rhs_common' lrwage lprod wrigid prodgrowth inflation_lc"
local rhs_B "`rhs_common' lrwage lseprt wrigid prodgrowth inflation_lc"

reg F.valLDR i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid d.lprod d.lprice [iw=DEN ], robust
reg F2.valLDR i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid d.lprod d.lprice [iw=DEN ], robust
reg F3.valLDR i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid d.lprod d.lprice [iw=DEN ], robust
reg F4.valLDR i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid d.lprod d.lprice [iw=DEN ], robust


horizon_coefs, depvar(valLDR) rhs("`rhs_A'") wtvar(DEN) covars("lrwage lprod inflation_lc")
matrix M_lsepr = r(results)
plot_horizon_coef, matname(M_lsepr) col(1) ytitle("Coefficient on log real wage") title("Real wage effect on fire rate, by horizon") filename("lrwage_valLDR_horizon.png")
plot_horizon_coef, matname(M_lsepr) col(3) ytitle("Coefficient on log productivity") title("Productivity effect on fire rate, by horizon") filename("lprod_valLDR_horizon.png")
plot_horizon_coef, matname(M_lsepr) col(5) ytitle("Coefficient on inflation") title("Inflation effect on fire rate, by horizon") filename("inflation_valLDR_horizon.png")


reg F.valQUR i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid d.lprod d.lprice [iw=DEN ], robust
reg F2.valQUR i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid d.lprod d.lprice [iw=DEN ], robust
reg F3.valQUR i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid d.lprod d.lprice [iw=DEN ], robust
reg F4.valQUR i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid d.lprod d.lprice [iw=DEN ], robust



horizon_coefs, depvar(valQUR) rhs("`rhs_A'") wtvar(DEN) covars("lrwage lprod inflation_lc")
matrix M_lsepr = r(results)
plot_horizon_coef, matname(M_lsepr) col(1) ytitle("Coefficient on log real wage") title("Real wage effect on quit rate, by horizon") filename("lrwage_valQUR_horizon.png")
plot_horizon_coef, matname(M_lsepr) col(3) ytitle("Coefficient on log productivity") title("Productivity effect on quit rate, by horizon") filename("lprod_valQUR_horizon.png")
plot_horizon_coef, matname(M_lsepr) col(5) ytitle("Coefficient on inflation") title("Inflation effect on quit rate, by horizon") filename("inflation_valQUR_horizon.png")



reg F.valHIR i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid d.lprod d.lprice [iw=DEN ], robust
reg F2.valHIR i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid d.lprod d.lprice [iw=DEN ], robust
reg F3.valHIR i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid d.lprod d.lprice [iw=DEN ], robust
reg F4.valHIR i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid d.lprod d.lprice [iw=DEN ], robust



horizon_coefs, depvar(valHIR) rhs("`rhs_A'") wtvar(DEN) covars("lrwage lprod inflation_lc")
matrix M_lsepr = r(results)
plot_horizon_coef, matname(M_lsepr) col(1) ytitle("Coefficient on log real wage") title("Real wage effect on hire rate, by horizon") filename("lrwage_valHIR_horizon.png")
plot_horizon_coef, matname(M_lsepr) col(3) ytitle("Coefficient on log productivity") title("Productivity effect on hire rate, by horizon") filename("lprod_valHIR_horizon.png")
plot_horizon_coef, matname(M_lsepr) col(5) ytitle("Coefficient on inflation") title("Inflation effect on hire rate, by horizon") filename("inflation_valHIR_horizon.png")

