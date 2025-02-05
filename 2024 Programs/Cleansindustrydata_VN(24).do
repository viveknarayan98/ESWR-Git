global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Data/Clean"

*Make a note about how industryfromexcel was created (was copied and pasted from ind_indnaics_crosswalk_2000_onward.xlsx)*
use industryfromexcel, clear



*Fixes variable names*
rename var1 industryname
rename var2 industrycode

destring industrycode, replace

*Cleans up entries*
replace industryname= "Arts, Entertainment, and Recreation" if industryname=="Arts, Entertainment, and Recreation:"
replace industryname= "Military" if industryname== "Active Duty Military:"
replace industryname= "Accommodation and Food Services" if industryname== "Accommodation and Food Services:"
replace industryname= "Government and government enterprises" if industryname== "Public Administration:"
replace industryname= "Nondurable goods manufacturing" if inrange(industrycode, 1070, 2390)
replace industryname= "Durable goods manufacturing" if inrange(industrycode, 2470, 3990)
replace industryname= "Transportation and warehousing" if inrange(industrycode,6070,6390)

gen industryname5= substr(industryname, 1, 5)


*Drops missing*
drop if industrycode==.
drop if industryname== "992"

save indcleaned, replace

* College line Code and merge
use integratedstategdp, clear
collapse(mean) LineCode, by(Description)
replace Description= strtrim(Description)
gen industryname5= substr(Description, 1, 5)
merge 1:m industryname5 using indcleaned
keep if _merge ==3
drop _merge

save indcleaned, replace 
