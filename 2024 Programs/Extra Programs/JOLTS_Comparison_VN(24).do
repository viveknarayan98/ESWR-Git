global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

cd "${mypath}/Data/Clean"

import excel "${mypath}/SeriesReportsBLS/JOLTS_Separations_0524.xlsx", sheet("BLS Data Series") cellrange(A4:IG20) firstrow clear

gen industrycode= substr(SeriesID, 4, 6)


merge 1:1 industrycode using jt_industry


keep if _merge==3

drop industrycode _merge *2024 SeriesID

ds industrydescription, not

rename (`r(varlist)') SepRate=

reshape long SepRate, i(industrydescription) j(MonthYear) string



*Extract date variables
gen month = substr(MonthYear,1,3)

gen year = substr(MonthYear,4,4)
destring year, replace

gen month1 = .

local stringmonths= "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"

local i =1

foreach x of local stringmonths {
replace month1= `i' if month=="`x'"
local i = `i' +1	
}

*Set up quarters
generate quarter = ceil(month1/3)

keep if inrange(year, 2005, 2023)

*Creates time variable in time format and then collapses available info

gen time= yq(year, quarter)
format time %tq

collapse(mean) SepRate, by(time year quarter industrydescription)

gen trimdescrip = substr(industrydescription, 1, 4)

merge 1:1 year quarter trimdescrip using mergedcollapsedcps

keep if _merge==3

gen CPSSeprate= EU/empdenom*100

gen JOLTSratio= SepRate/CPSSeprate

drop if LineCode==60
