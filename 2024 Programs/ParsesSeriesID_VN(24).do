*Set this to your own directory

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

import excel "${mypath}/Data/Raw/MasterSeries.xlsx", sheet("BLS Data Series") cellrange(A4:PE938) firstrow clear



*Preparing for reshape so that each date is a new row
local dates Jan* Feb* Mar* Apr* May* Jun* Jul* Aug* Sep* Oct* Nov* Dec*

foreach var of local dates{
	rename `var' employees`var'
}

*Reshapes
reshape long employees, i(SeriesID) j(MonthYear) string

*Pulls info from SeriesID based on https://www.bls.gov/help/hlpforma.htm#SM
gen statecode= substr(SeriesID, 4,2)
gen industry_code = substr(SeriesID, 11,8)
gen data_type_code =  substr(SeriesID, 19,2)


*Merge with state and industry codes
cd "${mypath}/Data/Clean"

merge m:1 statecode using statecodes
keep if _merge==3
drop _merge
merge m:1 industry_code using industrycodes
keep if _merge==3
drop _merge

replace industry_name="Educational Services" if industry_name=="Private Educational Services"
replace industry_name="Nondurable goods" if industry_name=="Non-Durable Goods"

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

collapse(mean) employees, by(time year quarter industry_name stname statecode)

destring statecode, replace
label var employees "thousands of employees"

replace industry_name= trim(industry_name)
gen trimdescrip = substr(industry_name, 1, 4)

egen identifier= group(trimdescrip time stname)

cd "${mypath}/Data/Clean"

merge 1:1 trimdescrip time stname using integratedstategdp

drop _merge

*Note that this is just the workers merged so far 
save employeesgdpmerged, replace
