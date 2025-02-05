*1947-1997 Inflation data"

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

cd "${mypath}/Data/Clean"
import excel "${mypath}/Data/Raw/Business Cycle Anatomy Data/AllTablesHist/GDPbyInd_VA_1947-1997.xlsx", sheet("ChainPriceIndexes") cellrange(A6:BA108) clear firstrow


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

local varlist C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA


renvarlab `varlist', label prefix(Inflation)

drop if Inflation1947=="..."

rename Line LineCode

reshape long Inflation, i(LineCode) j(year)

keep if inrange(year, 1979, 1996)

destring Inflation, replace

xtset LineCode year

save AnnualInflation_4797, replace

import excel "${mypath}/Data/Raw/BEA Download Region sector GDP/PriceIndices(97-23).xlsx", sheet("Table") clear cellrange(A6:AC111) firstrow

drop if AC==.

rename B Description 

destring Line, replace

replace Description= trim(Description)

duplicates drop Description, force


replace Description= "Durable goods manufacturing" if Description== "Durable goods"
replace Description= "Nondurable goods manufacturing" if Description== "Nondurable goods"
replace Description= "Mining, quarrying, and oil and gas extraction" if Description== "Mining"
replace Description= "Other services (except government and government enterprises)" if Description== "Other services, except government"
replace Description= "Agriculture, forestry, fishing and hunting" if Description=="Agriculture, forestry, fishing, and hunting"

local varlist C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC 

renvarlab `varlist', label prefix(Inflation)

*Get ready to merge so that everything is the 2012=100

gen reweightfactor= Inflation2012/Inflation2017

local Inflation Inflation1997 Inflation1998 Inflation1999 Inflation2000 Inflation2001 Inflation2002 Inflation2003 Inflation2004 Inflation2005 Inflation2006 Inflation2007 Inflation2008 Inflation2009 Inflation2010 Inflation2011 Inflation2012 Inflation2013 Inflation2014 Inflation2015 Inflation2016 Inflation2017 Inflation2018 Inflation2019 Inflation2020 Inflation2021 Inflation2022 Inflation2023

foreach var of local Inflation{
	replace `var' = `var'* reweightfactor
}

drop reweightfactor

rename Line LineCode

reshape long Inflation, i(LineCode) j(year)

append using AnnualInflation_4797

replace Description= "Leisure and hospitality" if Description== "Arts, entertainment, recreation, accommodation, and food services"
replace Description= "Financial activities" if Description== "Finance, insurance, real estate, rental, and leasing"

save AnnualInflation_final, replace
