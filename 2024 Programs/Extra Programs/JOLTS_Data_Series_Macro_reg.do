global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

cd "${mypath}/Data/Clean"


import excel "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git/Data/Raw/Macro Data Files/JOLTS_data.xlsx", sheet("BLS Data Series") cellrange(A4:LM84) firstrow allstring clear

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

label var valHIR Hires
label var valJOR "Job Openings"
label var valLDR "Layoff and discharges"
label var valOSR "Other Separations"
label var valQUR "Quits"

gen trimdescrip = substr(industrydescription, 1, 4)

gen qdate = qofd(dofm(date))
format qdate %tq

collapse (mean) valHIR valJOR valLDR valOSR valQUR, by(industrydescription trimdescrip qdate)

rename qdate time

cd "${mypath}/Programs/ESWR-Git/Data/Clean"

save JOLTS_macro_reg_series, replace
