global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"


import excel "${mypath}/Data/Raw/xwalks/ind_90-00.xls", sheet("Sheet1") cellrange(A6:B980) clear

rename A ind1990
rename B CPS_Description

gen Description=""

drop if ind1990==""
drop if CPS_Description==""

destring ind1990, replace

*Based on Acemoglu Crosswalk and https://usa.ipums.org/usa/volii/ind1990.shtml*

replace Description="Agriculture, Forestery, and Fisheries" if inrange(ind1990,10,32)
replace Description="Mining, quarrying, and oil and gas extraction" if inrange(ind1990, 40, 50)
replace Description="Construction" if ind1990==60
replace Description="Nondurable Goods" if inrange(ind1990, 100, 222)
replace Description="Durable Goods" if inrange(ind1990, 230, 392)
replace Description="Transportation and warehousing" if inrange(ind1990, 400, 432)
replace Description="Information" if inrange(ind1990, 440, 442)|ind1990==172|ind1990==732|inrange(ind1990,800,801)
replace Description="Utilities" if inrange(ind1990, 450, 472)
replace Description="Wholesale Trade" if inrange(ind1990, 500, 571)
replace Description="Retail Trade" if inrange(ind1990, 580, 691)
replace Description="Finance and Insurance" if inrange(ind1990, 700, 711)
replace Description="Real Estate and Rental and Leasing" if ind1990==712
replace Description="Professional, Scientific, and Technical Services" if ind1990==882|inrange(ind1990, 891, 893)|ind1990==841|ind1990==721|ind1990==732
replace Description="Management of Companies and Enterprises" if ind1990==892
replace Description="Administrative and support and waste management and remediation services" if ind1990==722|ind1990==731|ind1990==890
replace Description="Educational services" if inrange(ind1990, 842, 860)
replace Description="Health care and social assistance" if inrange(ind1990, 812, 840)|inrange(ind1990, 861, 871)|inrange(ind1990, 880, 881)
replace Description="Arts, entertainment, and recreation services" if inrange(ind1990, 802, 810)|ind1990==872
replace Description="Accommodation and food services" if inrange(ind1990, 762, 770)|ind1990==641
replace Description="Other Services" if inrange(ind1990, 740, 761)|inrange(ind1990, 771, 791)

cd "${mypath}/Data/Clean"

gen trimdescrip = substr(Description, 1, 4)

merge m:1 trimdescrip using Line_Code_Descrip

keep if _merge==3

drop _merge

save ind1990LCxwalk, replace
