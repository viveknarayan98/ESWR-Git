*****This file executes the macro regression***

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Data/Clean"

local quarterly=1

*Appending all the collapsed and merged CPS files

if `quarterly'==0{
	use merged_cps_0523, clear
	append using merged_cps_9304
	append using merged_cps_7992
}
else{
	use mergedcollapsedcps, clear
}

*Set time var
if `quarterly'==0{
	rename year time
	format time %ty 
	sort year LineCode
	save merged_cps_annual, replace
	}




*Set panel and time vars
xtset LineCode time

*Create hours
gen thours= hours*Employment


*Create productivity and inflation measures
gen prodh_i = GDP/thours
gen price_i = Inflation/l.Inflation
gen lprod= log(prodh_i)
gen lprice= log(price_i)
gen lrwage = log(wage/price_i)
gen lsep   = log(EU)
gen lhiresu = log(UE)
gen lhires = log(UE+NE)
gen lsep_a = log(EU+EN)
gen wrigid = wchange0/(wchange0 + wchangen + wchangep + EU)
gen lprod4 = log(GDP/(thours))
gen lrwage_rig = lrwage*wrigid
gen lprod_rig = lprod*wrigid
gen dlrwage = d.lrwage
gen dlprod  = d.lprod
gen dlsep   = d.lsep
gen dlrwage_rig = d.lrwage_rig
gen dlprod_rig  = d.lprod_rig
gen dlrwage_rig2 = d.lrwage*L.wrigid
gen dlprod_rig2  = d.lprod*L.wrigid

gen GDP_G = log(GDP) - log(L.GDP)

save merged_cps_annual, replace

*Run regression***

xtreg F.lsep   i.time age education* nWhite male unionm unionc GDP_G lrwage lprod wrigid, fe robust cluster(LineCode)
xtreg F.lprod  i.time age education* nWhite male unionm unionc GDP_G lrwage lsep  wrigid, fe robust cluster(LineCode)

*Create Wage Rigidty Figure
collapse(sum) wchangen wchange0 wchangep EU, by(year)

gen wrigid= wchange0/(wchangen+wchangep+EU+wchange0)*100

keep if year>1979

tsset year

label var wrigid "Wage Rigidity"
label var year "Year"

tsline wrigid



