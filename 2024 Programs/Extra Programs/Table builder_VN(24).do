clear all
cls

**Set directory
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Data/Clean"

**Build the full file
use fullcps0523mincer

append using fullcps9304mincer
append using fullcps7992mincer

**Keep required variables
keep year month cpsidp LineCode l_status mish empsame lnwage w_MIN* timecoef* constantcoef* ind1990 statefip unionm unionc educ nWhite age sex earnwt hours wtfinl


*Keep only the wage observations
keep if mish==4|mish==8

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

**Sets college education levels

gen collegeduc=1 if educ>=81
replace collegeduc=0 if educ<81


*Create dummy var for male*
gen male=1 if sex==1
replace male=0 if sex==2

*Creates dummy for either covered or member of union*

gen unionmorc=1 if unionm==1|unionc==1
replace unionmorc=0 if unionm==0 & unionc==0

*Create variables for unemployment, leaving labor force, and not working (leaving and unemployment combined) 
sort cpsidp time 

gen f12unemployed= F12.EU12

*Create full sample means
preserve 
collapse(mean) male collegeduc age nWhite [iw=wtfinl]

restore, preserve
gen wage = exp(lnwage)
collapse(mean) wage [aw=earnwt*hours]

restore, preserve
collapse(mean) hours unionmorc EU12 [aw=earnwt]

restore

*Create by the year samples

keep if year==1980|year==1981|year==1982

preserve 
collapse(mean) male collegeduc age nWhite [iw=wtfinl], by(year)

restore, preserve
gen wage = exp(lnwage)
collapse(mean) wage [aw=earnwt*hours], by(year)

restore, preserve
collapse(mean) hours unionmorc EU12 [aw=earnwt], by(year)

*Macro tables

use merged_cps_annual, clear

collapse(sum) GDP thours, by(year)

gen outputperhour= GDP/thours

sort year 

local prod2001 = outputperhour[23]
local GDP2001 = GDP[23]

*Index to 2001 value as 100
replace GDP= (GDP/`GDP2001')*100
replace outputperhour= (outputperhour/`prod2001')*100

label variable outputperhour "Output per hour"
label variable GDP "GDP"
label variable year "Year"

tsline GDP outputperhour, ytitle("Index (2001=100)")

graph export GDP_Prod.jpg, replace

*Wage Rigidity Graph

use fullcps_microreg, clear

collapse(sum) wchange0 wchangen wchangep [aw=earnwt], by(year)

gen wrigid= wchange0/(wchangen + wchange0)*100

label variable wrigid "Wage Rigidity"
label variable year "Year"

tsset year

tsline wrigid

graph export Wage_Rigidty.jpg, replace


