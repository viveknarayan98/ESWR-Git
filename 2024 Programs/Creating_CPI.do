**This program intends to create an employment-weighted deflator for each industry by 
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"


*****IMPORT NOMINAL GDP*****

import delimited "${mypath}/Data/Raw/Macro Data Files/SQGDP/SQGDP2__ALL_AREAS_2005_2023.csv", clear

*renames variables to their labels so that we can identify them
ssc install renvarlab
renvarlab *, label

*tells us which variables are not strings and should be converted
describe

*Note that for some reason years 2006 and 2007 are float 


foreach name in "_2006_Q1" "_2006_Q2" "_2006_Q3" "_2006_Q4" "_2007_Q1" "_2007_Q2" "_2007_Q3" "_2007_Q4" {
	    capture drop `name'2
		    tostring `name', gen(`name'2) force
			    drop `name'
}

drop if GeoName==""

*reshape

drop if LineCode==. 
reshape long _, i(GeoName Description) j(date) string

*create data variables and make them numeric
gen year= substr(date, 1, 4)
gen quarter = substr(date, 7, 1)
destring year, generate(years)
destring quarter,  generate(quarters)

drop year quarter
rename years year
rename quarters quarter

gen yq= yq(year, quarter)
format yq %tq

tab _ if missing(real(_))
destring _, force replace

rename _ NominalGDP

*create statefips
gen geofips= substr(GeoFIPS, 3, 5)
destring geofips, replace

gen statefips= geofips/1000

cd "${mypath}/Data/Clean"

save NominalGDP_All_Areas, replace 

*****IMPORT REAL GDP*****

import delimited "${mypath}/Data/Raw/Macro Data Files/SQGDP/SQGDP9__ALL_AREAS_2005_2023.csv", clear
*renames variables to their labels so that we can identify them
ssc install renvarlab
renvarlab *, label

*tells us which variables are not strings and should be converted
describe

*Note that for some reason years 2006 and 2007 are float 


foreach name in "_2006_Q1" "_2006_Q2" "_2006_Q3" "_2006_Q4" "_2007_Q1" "_2007_Q2" "_2007_Q3" "_2007_Q4" {
	    capture drop `name'2
		    tostring `name', gen(`name'2) force
			    drop `name'
}

drop if GeoName==""

*reshape

drop if LineCode==. 
reshape long _, i(GeoName Description) j(date) string

*create data variables and make them numeric
gen year= substr(date, 1, 4)
gen quarter = substr(date, 7, 1)
destring year, generate(years)
destring quarter,  generate(quarters)

drop year quarter
rename years year
rename quarters quarter

gen yq= yq(year, quarter)
format yq %tq

tab _ if missing(real(_))
destring _, force replace

rename _ RealGDP

*create statefips
gen geofips= substr(GeoFIPS, 3, 5)
destring geofips, replace

gen statefips= geofips/1000

merge 1:1 statefips yq LineCode using NominalGDP_All_Areas

keep if LineCode==2
 
gen deflator= NominalGDP/RealGDP

drop _merge LineCode IndustryClassification GeoFIPS Description date Region Unit year quarter geofips

rename statefips statefip

erase "NominalGDP_All_Areas.dta"
save Nominal_Real_GDP_All_Areas, replace


****Share of employment contributed by each state***
use fullcps0523, clear

keep if month==3|month==6|month==9|month==12
gen yq= yq(year,quarter)
format yq %tq

gen employed=l_status==1

collapse(sum) employed [aw=wtfinl], by(yq statefip LineCode)

bysort LineCode yq: egen double emp_tot = total(employed)
gen double state_share = employed / emp_tot

merge m:1 yq statefip using Nominal_Real_GDP_All_Areas
keep if _merge==3


gen emp_weighted_deflator= deflator*state_share
collapse(sum) emp_weighted_deflator, by (yq LineCode)


