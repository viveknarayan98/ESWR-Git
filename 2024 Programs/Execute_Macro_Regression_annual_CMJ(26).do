*****This file executes the macro regression***
* Housekeeping
clear
cls

* Declare user
global user = "c"

* Global folder
if "$user"=="v" {
	global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"
}
if "$user"=="c" {
	global mypath "/mq/scratch/m1cxm05/ESWR"
}

* Login into folder
cd "${mypath}/Data/Clean"

* Load data
use merged_cps_annual, clear
gen time = year

*Set panel and time vars
tsset LineCode time
 
*Create productivity and inflation measures
gen lrwage = log(wage/price_i)
gen lsep   = log(EU)
gen lhiresu = log(UE)
gen lhires = log(UE+NE)
gen lsep_a = log(EU+EN)
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
egen trend = group(time)
gen trend2 = trend^2

gen lsepr      = log(EU/(EU+EN+EE))
gen lseprt     = log((EU+EN)/(EU+EN+EE))
gen DEN        = EU+EN+EE
gen prodgrowth = d.lprod
gen inflation_lc  = d.lprice


reg F.lsepr i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F2.lsepr i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F3.lsepr i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F4.lsepr i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust

reg F.lseprt i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F2.lseprt i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F3.lseprt i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F4.lseprt i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust

reg F.lprod i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lseprt wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F2.lprod i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lseprt wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F3.lprod i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lseprt wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F4.lprod i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lseprt wrigid prodgrowth  inflation_lc [iw=DEN ], robust


reg F.lhires i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F2.lhires i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F3.lhires i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust
reg F4.lhires i.time c.trend##i.LineCode c.trend2##i.LineCode  age education* nWhite male unionm unionc GDP_G lrwage  lprod wrigid prodgrowth  inflation_lc [iw=DEN ], robust

