*Append matched files into one big file

clear all
set more off

cd "$dta"

local x = 199401
// *Destring hrhhid
 while `x'<=202211{
 if `x' != 197712 & `x' != 198506 & `x' != 198509 & `x' != 199312 & `x' != 199505 & `x' != 199506 & `x' != 199507 & `x' != 199508{
 	use matched`x'.dta
 destring hrhhid hrhhid2, replace force
 save matched`x'.dta,  replace
}
 	local x = `x' + 1
 	if (`x'-13)/100 == int((`x'-13)/100) {
 	local x = `x' + 88
 }
 }
clear

*++++++++++++++++++++++++++++ 
use  matched199401.dta, clear
*use  cps_all_matched.dta, clear
save cps_all_matched.dta, replace
*++++++++++++++++++++++++++++ 

local x=199402

while `x'<=202211{
di `x'
if `x' != 197712 & `x' != 198506 & `x' != 198509 & `x' != 199312 & `x' != 199505 & `x' != 199506 & `x' != 199507 & `x' != 199508{
append using matched`x'.dta
save cps_all_matched.dta, replace
}
local x = `x' + 1
if (`x'-13)/100 == int((`x'-13)/100) {
    local x = `x' + 88
}
}

