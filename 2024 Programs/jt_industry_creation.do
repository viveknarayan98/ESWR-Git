global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"

cd "${mypath}/Data/Raw"


! curl -sL -A "vnarayan98@gmail.com" ///
    "https://download.bls.gov/pub/time.series/jt/jt.industry" ///
    -o jt_industry.txt

! head -3 jt_industry.txt   // sanity check: should show the header row

import delimited "jt_industry.txt", delimiter(tab) varnames(1) stringcols(_all) clear

ds
local v1 : word 1 of `r(varlist)'
local v2 : word 2 of `r(varlist)'
keep `v1' `v2'
rename `v1' industrycode
rename `v2' industrydescription

replace industrycode        = strtrim(industrycode)
replace industrydescription = strtrim(industrydescription)

list, clean noobs

cd "${mypath}/Data/Clean"

save jt_industry, replace
