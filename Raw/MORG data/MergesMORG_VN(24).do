global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Data/Clean"

use "${mypath}/Data/Raw/MORG data/earnings_1979_1981.dta", clear
preserve
keep if year==1979
duplicates drop year month cpsidp, force

save 79morgearnings, replace

use "${mypath}/Data/Raw/Original CPS Downloads/cps_00043.dta"
duplicates drop year month cpsidp, force

merge 1:1 year month cpsidp using 79morgearnings

save 79morgearnings, replace

restore


keep if inrange(year, 1980, 1981)

*Nothing gets deleted here

duplicates drop year month cpsidp, force

save 8081morgearnings, replace

use "${mypath}/Data/Raw/Original CPS Downloads/cps_00038.dta" 


duplicates drop year month cpsidp, force

merge 1:1 year month cpsidp using 8081morgearnings
 
drop _merge

save 8081morgearnings, replace 
