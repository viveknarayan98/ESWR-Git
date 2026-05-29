*===============================================================
* Build Annual Inflation Index (spliced at 1997)
* Rescales the 1997-2023 file so its 1997 value matches the
* 1947-1997 file industry-by-industry, ensuring continuity.
*===============================================================

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"
cd "${mypath}/Data/Clean"


*--------------------------------------------------------------
* STEP 1: Load 1947-1997 file, extract 1997 anchor values,
*         then save 1979-1996 data
*--------------------------------------------------------------
import excel "${mypath}/Data/Raw/Macro Data Files/GDPbyInd_VA_1947-1997.xlsx", ///
    sheet("ChainPriceIndexes") cellrange(A6:BA108) clear firstrow

drop if BA==""
rename B Description
destring Line, replace
* Strip non-breaking spaces (char 160) that Excel embeds, then normalize whitespace
replace Description = subinstr(Description, char(160), " ", .)
replace Description = itrim(trim(Description))
duplicates drop Description, force

replace Description = "Durable goods manufacturing"                                          if Description == "Durable goods"
replace Description = "Nondurable goods manufacturing"                                       if Description == "Nondurable goods"
replace Description = "Mining, quarrying, and oil and gas extraction"                        if Description == "Mining"
replace Description = "Other services (except government and government enterprises)"        if Description == "Other services, except government"
replace Description = "Agriculture, forestry, fishing and hunting"                           if Description == "Agriculture, forestry, fishing, and hunting"

local varlist C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA
renvarlab `varlist', label prefix(Inflation)

drop if Inflation1947 == "..."
rename Line LineCode

* Build a stripped merge key: lowercase, no spaces or punctuation.
* This survives any remaining hidden-character differences between the two files.
gen desc_key = lower(Description)
replace desc_key = ustrregexra(desc_key, "[^a-z0-9]", "")

* Save 1997 anchor keyed by desc_key (not LineCode or raw Description).
preserve
    destring Inflation1997, replace force
    keep desc_key Inflation1997
    rename Inflation1997 anchor1997
    save anchor1997, replace
restore
drop desc_key

* Reshape and save 1979-1996 series
reshape long Inflation, i(LineCode) j(year)
keep if inrange(year, 1979, 1996)
destring Inflation, replace
xtset LineCode year
save AnnualInflation_4797, replace


*--------------------------------------------------------------
* STEP 2: Load 1997-2023 file, splice to old file at 1997
*--------------------------------------------------------------
import excel "${mypath}/Data/Raw/Macro Data Files/PriceIndices(97-23).xlsx", ///
    sheet("Table") clear cellrange(A6:AC111) firstrow

drop if AC == .
rename B Description
destring Line, replace
* Strip non-breaking spaces (char 160) that Excel embeds, then normalize whitespace
replace Description = subinstr(Description, char(160), " ", .)
replace Description = itrim(trim(Description))
duplicates drop Description, force

replace Description = "Durable goods manufacturing"                                          if Description == "Durable goods"
replace Description = "Nondurable goods manufacturing"                                       if Description == "Nondurable goods"
replace Description = "Mining, quarrying, and oil and gas extraction"                        if Description == "Mining"
replace Description = "Other services (except government and government enterprises)"        if Description == "Other services, except government"
replace Description = "Agriculture, forestry, fishing and hunting"                           if Description == "Agriculture, forestry, fishing, and hunting"

local varlist C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC
renvarlab `varlist', label prefix(Inflation)
rename Line LineCode

* Build the same stripped merge key as in the old file
gen desc_key = lower(Description)
replace desc_key = ustrregexra(desc_key, "[^a-z0-9]", "")

* Merge anchor values by desc_key — immune to hidden characters, spacing
* differences, or punctuation variation between the two BEA file vintages.
merge 1:1 desc_key using anchor1997, keep(match master) nogenerate
drop desc_key

* Reweight factor: scale each industry so its 1997 value matches the old file
* After this, new_Inflation1997 = anchor1997 for every industry
gen reweightfactor = anchor1997 / Inflation1997

local Inflation Inflation1997 Inflation1998 Inflation1999 Inflation2000 ///
    Inflation2001 Inflation2002 Inflation2003 Inflation2004 Inflation2005 ///
    Inflation2006 Inflation2007 Inflation2008 Inflation2009 Inflation2010 ///
    Inflation2011 Inflation2012 Inflation2013 Inflation2014 Inflation2015 ///
    Inflation2016 Inflation2017 Inflation2018 Inflation2019 Inflation2020 ///
    Inflation2021 Inflation2022 Inflation2023

foreach var of local Inflation {
    replace `var' = `var' * reweightfactor
}

drop reweightfactor anchor1997


*--------------------------------------------------------------
* STEP 3: Reshape, append, and build inflation rate
*--------------------------------------------------------------
reshape long Inflation, i(LineCode) j(year)

append using AnnualInflation_4797

replace Description = "Leisure and hospitality"   if Description == "Arts, entertainment, recreation, accommodation, and food services"
replace Description = "Financial activities"       if Description == "Finance, insurance, real estate, rental, and leasing"

xtset LineCode year
rename Inflation Inflation_index

* Year-over-year inflation rate
gen inflation = D.Inflation_index / L.Inflation_index

save AnnualInflation_final, replace

merge 1:1 year Description using AnnualGDP_final

keep if _merge==3

save annual_inflation_gdp, replace
