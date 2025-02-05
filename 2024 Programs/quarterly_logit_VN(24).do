global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

cd "${mypath}/Data/Clean"

use mergedcollapsedcps, clear

drop if empdenom<30

*replace EU= EU/empdenom

gen prodh_i = RealGDP/thours
gen price_i = NominalGDP/RealGDP

gen lrwage = log(wage/price_i)
gen lprod  = log(prodh_i)
gen lsep   = log(EU)
gen lhiresu = log(UE)
gen lhires = log(UE+NE)
gen lsep_a = log(EU+EN)
gen lprice = log(price_i)
gen wrigid = wchange0/(wchange0 + wchangen)
gen lprod4 = log(RealGDP/(thours))

gen lrwage_rig = lrwage*wrigid
gen lprod_rig = lprod*wrigid


sort LineCode statefip time 

drop identifier
egen identifier= group(LineCode statefip)

tsset identifier time

gen dlrwage = d.lrwage
gen dlprod  = d.lprod
gen dlsep   = d.lsep
gen dlrwage_rig = d.lrwage_rig
gen dlprod_rig  = d.lprod_rig
gen dlrwage_rig2 = d.lrwage*L.wrigid
gen dlprod_rig2  = d.lprod*L.wrigid


xtreg F.lsep   i.year age education* nWhite male unionm unionc lrwage lprod wrigid, fe robust cluster(identifier)
xtreg F.lhires i.year age education* nWhite male unionm unionc lrwage lprod wrigid, fe robust
xtreg F.lprod  i.year age education* nWhite male unionm unionc lrwage lsep  wrigid, fe robust cluster(identifier)
xtreg F.lprice i.year age education* nWhite male unionm unionc lrwage lsep lprod wrigid, fe robust

save empiricalmodel, replace

use ind1990LCxwalk, clear

collapse(mean) LineCode, by(trimdescrip)

merge 1:m LineCode using empiricalmodel

drop _merge 


save empiricalmodel, replace

use statecodes, clear

destring statecode, replace

rename statecode statefip

merge 1:m statefip using empiricalmodel 

keep lsep age education* nWhite male unionm unionc lrwage lprod wrigid time trimdescrip stname

reshape wide lsep age education* nWhite male unionm unionc lrwage lprod wrigid, i(time stname) j(trimdescrip) string 





