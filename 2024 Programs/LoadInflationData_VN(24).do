*

global mypath "/Users/viveknarayan/Documents/vivek_camilo_project Rob Chen"

cd "${mypath}/Data/Clean"

*Note that 2012=100

import excel "/Users/viveknarayan/Documents/vivek_camilo_project Rob Chen/Data/Raw/Business Cycle Anatomy Data/AllTablesHist/GDPbyInd_VA_1947-1997.xlsx", sheet("ChainPriceIndexes") cellrange(A6:BA108) clear firstrow

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

save AnnualPriceIndices_47-97, replace

import excel "/Users/viveknarayan/Documents/vivek_camilo_project Rob Chen/Data/Raw/BEA Download Region sector GDP/PriceIndices(97-23).xlsx", sheet("Table") cellrange(A7:AC111) firstrow clear


rename B Description

replace Description= trim(Description)

drop if AC==.

destring Line, replace

*We see the duplicates are government enterprises which is not relevant for us
duplicates list Description

*Drop duplicates
duplicates drop Description, force

merge 1:1 Description using AnnualGDP_4797

*keep if _merge==3

rename Line LineCode

keep if LineCode==3|LineCode==6|LineCode==10|LineCode==11|LineCode==13|LineCode==25|LineCode==34|LineCode==35|LineCode==36|LineCode==45|LineCode==50|LineCode==59|LineCode==68|LineCode==75|LineCode==82

drop geofips geoname region tablename industryclassification unit _merge Line

local varlist v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA

drop v9


renvarlab `varlist', label prefix(GDP)

destring GDP*, replace

reshape long GDP, i(LineCode) j(year)

keep if year>=1979

