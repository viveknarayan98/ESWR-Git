global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"


*Import Nominal GDP data*

import delimited "${mypath}/Data/Raw/BEA Download Region sector GDP/SQGDP/SQGDP2_US_2005_2023.csv", clear 

*renames variables to their labels so that we can identify them
ssc install renvarlab
renvarlab *, label

*tells us which variables are not strings and should be converted
describe

*Note that for some reason years 2006 and 2007 are float 

/*
foreach name in "_2006_Q1" "_2006_Q2" "_2006_Q3" "_2006_Q4" "_2007_Q1" "_2007_Q2" "_2007_Q3" "_2007_Q4" {
	    capture drop `name'2
		    tostring `name', gen(`name'2) force
			    drop `name'
}

drop if GeoName==""
*/

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

*make the GDP data numeric
*tab _ if missing(real(_))
*destring _, force replace

rename _ NominalGDP

*create statefips
gen geofips= substr(GeoFIPS, 3, 5)
destring geofips, replace

gen statefips= geofips/1000

cd "${mypath}/Data/Clean"
saveold nominalgdpdata, replace 


****Repeat for Real GDP****

import delimited "${mypath}/Data/Raw/BEA Download Region sector GDP/SQGDP/SQGDP9_US_2005_2023.csv", clear 

*renames variables to their labels so that we can identify them
ssc install renvarlab
renvarlab *, label

*tells us which variables are not strings and should be converted
describe

*Note that for some reason years 2006 and 2007 are float 

/*
foreach name in "_2006_Q1" "_2006_Q2" "_2006_Q3" "_2006_Q4" "_2007_Q1" "_2007_Q2" "_2007_Q3" "_2007_Q4" {
	    capture drop `name'2
		    tostring `name', gen(`name'2) force
			    drop `name'
}
*/

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

*make the GDP data numeric
*tab _ if missing(real(_))
*destring _, force replace

rename _ RealGDP

*create statefips
gen geofips= substr(GeoFIPS, 3, 5)
destring geofips, replace

gen statefips= geofips/1000

cd "${mypath}/Data/Clean"
save realgdpdata, replace

*Merges Real GDP with Nominal GDP

merge 1:1 GeoName LineCode yq using nominalgdpdata


keep year quarter statefips LineCode NominalGDP RealGDP Description GeoName
order year quarter statefips LineCode NominalGDP RealGDP Description GeoName


* We drop these lines becuase these lines are: total, total private, manufacturing (sum of durable and nondurable), and government (all "sectors")
drop if LineCode<3 | LineCode == 12 | LineCode>=83
drop if statefips>56

gen time = yq(year, quarter)
format time %tq

*Important steps for ensuring merge possibility
replace Description= trim(Description)

gen trimdescrip= substr(Description, 1 , 4)

egen identifier= group(trimdescrip time GeoName)

rename GeoName stname 

save integratedstategdp, replace

collapse(mean) LineCode, by(trimdescrip)

save Line_Code_Descrip, replace



