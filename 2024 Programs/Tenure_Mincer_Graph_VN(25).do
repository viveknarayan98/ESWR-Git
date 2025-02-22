
clear all
cls

**Set directory
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Data/Clean"

*Use dataset
use fullcps0523mincer, clear

keep if inrange(age, 25, 55)

keep w_MINwindow empsame cpsidp year month 

append using fullcps7992mincer

keep w_MINwindow empsame cpsidp year month 

keep if year>=1994

merge 1:1 year month cpsidp using "/Users/viveknarayan/Downloads/cps_00048.dta"

drop if _merge==2

gen time= ym(year, month)

xtset cpsidp time




collapse(mean) mean_mincer= w_MINwindow (semean) se_mincer= w_MINwindow [aw=jtsuppwt], by(jtyears)

