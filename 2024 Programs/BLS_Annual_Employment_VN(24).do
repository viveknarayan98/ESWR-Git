global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

cd "${mypath}/Data/Clean"

import delimited "${mypath}/SeriesReportsBLS/ce.industry.txt", clear 

save ce_industry_codes, replace

import excel "${mypath}/SeriesReportsBLS/Employmentbysector79-2023.xlsx", sheet("BLS Data Series") cellrange(A4:AU18) firstrow clear

gen industry_code= substr(SeriesID, 4, 8)

destring industry_code, replace

merge 1:1 industry_code using ce_industry_codes

keep if _merge==3

drop Annual2024 publishing_status naics_code _merge display_level selectable sort_sequence

reshape long Annual, i(SeriesID) j(year)

rename Annual Employment

drop SeriesID industry_code

replace industry_name= "Durable goods manufacturing" if industry_name== "Durable goods"
replace industry_name= "Nondurable goods manufacturing" if industry_name== "Nondurable goods"
replace industry_name= "Educational services, health care, and social assistance" if industry_name== "Private education and health services"
replace industry_name= "Other services (except government and government enterprises)" if industry_name=="Other services"

gen Description= substr(industry_name, 1, 70)
gen trimdescrip= substr(Description, 1, 4)

drop industry_name

merge 1:1 year Description using AnnualGDP_final

keep if _merge==3

drop _merge

merge 1:1 year Description using AnnualInflation_final

keep if _merge==3

drop _merge

merge m:1 trimdescrip using Line_Code_Descrip_Annual



drop _merge

save emp_gdp_inf_annual, replace
