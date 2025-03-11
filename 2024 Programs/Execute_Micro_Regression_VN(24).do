**Set directory
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Data/Clean"


**Keep required variables
use year month cpsidp LineCode l_status mish empsame lnwage ind1990 statefip unionm unionc educ nWhite age sex earnwt hours gradeate occ_g marst hours using fullcps, clear

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

*Keep only the wage observations in labor force
keep if mish==4|mish==8
keep if l_status!=3

**Sets diff education levels

*HS Grad*
gen educationlevel= 2 if educ==73

*HS Dropout*
replace educationlevel=1 if educ<73

*Some College*
replace educationlevel=3 if inrange(educ, 81, 92)

*College Grad*
replace educationlevel=4 if educ==111

*Postgrad*
replace educationlevel=5 if educ>111

**Generating wage
*gen lnwage_WINDOW= timecoef_MINwindow+ constantcoef_MINwindow + w_MINwindow 
*gen lnwage_WHOLE= timecoef_MINwhole+ constantcoef_MINwhole + w_MINwhole

**Merging with CPS figures

merge m:1 year LineCode using merged_cps_annual

keep if _merge==3

drop _merge EE EU EN UE NE empdenom wage Employment EmploymentCPS male thours


*Create dummy var for male*
gen male=1 if sex==1
replace male=0 if sex==2

*Creates dummy for either covered or member of union*

gen unionmorc=1 if unionm==1|unionc==1
replace unionmorc=0 if unionm==0 & unionc==0

*Create variables for unemployment, leaving labor force, and not working (leaving and unemployment combined) 
sort cpsidp time 

gen f12unemployed= F12.EU12
gen f12leftlf= F12.EN12
gen f12notworking=F12.ENE12

*ssc install egenmore, replace

*egen quint= xtile(lnwage), n(5) by(time)

save fullcps_microreg, replace

*Execute micro regression*
egen clustergroup = group(statefip LineCode)

logit f12unemployed  age gradeate i.occ_g i.educationlevel i.year i.statefip i.LineCode GDP_G nWhite male lprod wrigid lprice lnwage [iw=earnwt], cluster(LineCode)
