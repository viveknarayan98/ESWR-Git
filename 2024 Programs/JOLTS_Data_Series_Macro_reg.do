global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"

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

reg F.valLDR c.trend##i.LineCode i.time  age education* nWhite male unionm unionc GDP_G lrwage lprod wrigid [iw=EmploymentCPS], robust 
