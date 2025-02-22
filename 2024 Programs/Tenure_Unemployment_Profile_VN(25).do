**Set directory
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Data/Clean"

**Build the full file
use fullcps0523, clear

drop LineCode 
merge m:1 ind1990 using ind1990LCxwalk_annual
drop _merge Description CPS_Description trimdescrip


append using fullcps9304
append using fullcps7992

**Keep required variables
keep year month cpsidp LineCode l_status mish empsame lnwage ind1990 statefip unionm unionc educ nWhite age sex earnwt hours gradeate occ_g marst hours

*Should be redundant but do as a check
keep if inrange(age, 25, 55)


**Set panel
gen time = ym(year, month)
format time %tm
sort cpsidp time
tsset cpsidp time
tsset cpsidp time

**Define separations
gen EU12 = 0 if L12.l_status==1 & l_status!=.
replace EU12 = 1 if EU12==0 & (l_status==2 | L.l_status==2 | L2.l_status==2 | L3.l_status==2)  & (l_status!=3 & L.l_status!=3 & L2.l_status!=3 & L3.l_status!=3)


gen EN12 = 0 if L12.l_status==1 & l_status!=.
replace EN12 = 1 if EN12==0 & (l_status==3 | L.l_status==3 | L2.l_status==3 | L3.l_status==3)  & (l_status!=2 & L.l_status!=2 & L2.l_status!=2 & L3.l_status!=2)

gen ENE12 = 0 if L12.l_status==1 & l_status!=.
replace ENE12 = 1 if ENE12==0 & (l_status==2 | L.l_status==2 | L2.l_status==2 | L3.l_status==2 | l_status==3 | L.l_status==3 | L2.l_status==3 | L3.l_status==3) 

*Create variables for unemployment, leaving labor force, and not working (leaving and unemployment combined) 
sort cpsidp time 

gen f12unemployed= F12.EU12
gen f12leftlf= F12.EN12
gen f12notworking=F12.ENE12

*Merge with 
merge 1:1 year month cpsidp using "/Users/viveknarayan/Downloads/cps_00048.dta"

replace jtyears= ceil(jtyears)


keep if inrange(jtyears, 1, 30)


save fullcps_jtyears, replace

collapse(mean) mean_unemployed= f12unemployed (semean) se_unemployed= f12unemployed [aw=jtsuppwt], by(jtyears)

tsset jtyears

twoway (rarea lower_ci upper_ci jtyears, color(gs10)) (tsline mean_unemployed, lcolor(blue) lwidth(medium)), ytitle("Unemployment rate") xtitle("Job tenure") title("Unemployment rate over length of time at current job") legend(order(2 "Unemployment rate" 1 "95% CI"))

graph export "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Data/Clean/Unemployment Rate by Job Tenure.jpg", as(jpg) name("Graph") quality(100)





