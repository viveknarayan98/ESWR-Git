global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

cd "${mypath}/Data/Clean"

import excel "${mypath}/SeriesReportsBLS/2005-23_Monthly_Employment.xlsx", sheet("BLS Data Series") cellrange(A4:HU23) firstrow clear

gen industry_code= substr(SeriesID, 4, 8)

destring industry_code, replace

merge 1:1 industry_code using ce_industry_codes

keep if _merge==3

drop _merge industry_code naics_code publishing_status display_level selectable sort_sequence SeriesID

ds industry_name, not 

rename (`r(varlist)') Employment=

reshape long Employment, i(industry_name) j(MonthYear) string

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

collapse(mean) Employment, by(time year quarter industry_name)

*Need to replace education to match GDP data
replace industry_name= "Educational Services" if industry_name== "Private educational services"

gen trimdescrip= substr(industry_name, 1, 4)

merge 1:1 year quarter trimdescrip using integratedstategdp

keep if _merge==3

drop _merge

save employeesgdpmerged, replace
