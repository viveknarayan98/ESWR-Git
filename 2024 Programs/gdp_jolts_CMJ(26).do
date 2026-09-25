* Housekeeping
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


*Import Nominal GDP data*

import delimited "${mypath}/Data/Raw/Macro Data Files/sqgdp2.csv", varnames(4) rowrange(4) clear 

*renames variables to their labels so that we can identify them
ssc install renvarlab
renvarlab *, label

*tells us which variables are not strings and should be converted
describe


*reshape
drop if LineCode==. 
reshape long _, i(GeoName Description) j(date) string

*create data variables and make them numeric
gen year = substr(date, 1, 4)
gen quarter = substr(date, 7, 1)
destring year, generate(years)
destring quarter,  generate(quarters)

drop year quarter
rename years year
rename quarters quarter

gen yq= yq(year, quarter)
format yq %tq

rename _ NominalGDP

*create statefips
gen geofips= substr(GeoFIPS, 3, 5)
destring geofips, replace
gen statefips= geofips/1000

cd "${mypath}/Data/Clean"
saveold nominalgdpdata_jolts, replace 


****Repeat for Real GDP****
import delimited "${mypath}/Data/Raw/Macro Data Files/sqgdp9.csv", varnames(4) rowrange(4) clear 

*renames variables to their labels so that we can identify them
ssc install renvarlab
renvarlab *, label

*tells us which variables are not strings and should be converted
describe

drop if LineCode==.
drop if GeoName==""

*reshape
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


rename _ RealGDP

*create statefips
gen geofips= substr(GeoFIPS, 3, 5)
destring geofips, replace

gen statefips= geofips/1000

cd "${mypath}/Data/Clean"
save realgdpdata, replace

*Merges Real GDP with Nominal GDP
merge 1:1 LineCode yq using nominalgdpdata_jolts

keep year quarter statefips LineCode NominalGDP RealGDP Description 
order year quarter statefips LineCode NominalGDP RealGDP Description 


* We drop these lines becuase these lines are: total, total private, manufacturing (sum of durable and nondurable), and government (all "sectors")
drop if LineCode<3 | LineCode == 12 | LineCode>=83
drop if statefips>56

gen time = yq(year, quarter)
format time %tq

*Important steps for ensuring merge possibility
replace Description= trim(Description)

replace Description = "Professional and Business Services" if inrange(LineCode, 60, 65)
replace LineCode= 60 if inrange(LineCode, 64, 65)

*This is combining transportation, warehousing, and utilities
replace Description = "Transportation, warehousing, and utilities" if LineCode==36|LineCode==10
replace LineCode= 36 if LineCode==10

gen trimdescrip= substr(Description, 1 , 4)

collapse(sum) NominalGDP RealGDP, by (time year quarter LineCode Description trimdescrip)



save integratedstategdp_jolts, replace






