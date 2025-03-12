*1947-1997 GDP data"

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"

cd "${mypath}/Data/Clean"

import excel "${mypath}/Data/Raw/Macro Data Files/GDPbyInd_VA_1947-1997.xlsx", sheet("VA") cellrange(A6:BA114) clear firstrow

drop if BA==""

rename B Description 

destring Line, replace

replace Description= trim(Description)

duplicates drop Description, force


replace Description= "Durable goods manufacturing" if Description== "Durable goods"
replace Description= "Nondurable goods manufacturing" if Description== "Nondurable goods"
replace Description= "Mining, quarrying, and oil and gas extraction" if Description== "Mining"
replace Description= "Other services (except government and government enterprises)" if Description== "Other services, except government"
replace Description= "Agriculture, forestry, fishing and hunting" if Description=="Agriculture, forestry, fishing, and hunting"

save AnnualGDP_4797, replace

import delimited "${mypath}/Data/Raw/Macro Data Files/SAGDP2N__ALL_AREAS_1997_2023.csv", clear 

rename description Description

replace Description= trim(Description)


keep if geoname=="United States *"

merge 1:1 Description using AnnualGDP_4797

*keep if _merge==3

rename linecode LineCode

keep if LineCode==3|LineCode==6|LineCode==10|LineCode==11|LineCode==13|LineCode==25|LineCode==34|LineCode==35|LineCode==36|LineCode==45|LineCode==50|LineCode==59|LineCode==68|LineCode==75|LineCode==82

drop geofips geoname region tablename industryclassification unit _merge Line

local varlist v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA

drop v9

renvarlab `varlist', label prefix(GDP)

destring GDP*, replace

reshape long GDP, i(LineCode) j(year)

keep if year>=1979

xtset LineCode year

replace Description= "Leisure and hospitality" if Description== "Arts, entertainment, recreation, accommodation, and food services"
replace Description= "Financial activities" if Description== "Finance, insurance, real estate, rental, and leasing"

gen GDP_Growth= D.GDP/L.GDP

save AnnualGDP_final, replace

tsline GDP_Growth, by(Description)

gen trimdescrip= substr(Description, 1 , 4)

collapse (mean) LineCode, by(trimdescrip)

save Line_Code_Descrip_Annual, replace


