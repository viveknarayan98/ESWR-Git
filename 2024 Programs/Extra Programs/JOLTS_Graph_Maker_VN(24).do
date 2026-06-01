*Setting directory

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

cd "${mypath}/Data/Clean"

*Imports the JOLTS data
import excel "${mypath}/SeriesReportsBLS/JOLTS_Separationsbytype_0124.xlsx", sheet("BLS Data Series") cellrange(A4:JQ48) firstrow clear

gen data_element= substr(SeriesID, 19, 2)

gen industrycode= substr(SeriesID, 4, 6)

*Merge with industry codes
merge m:1 industrycode using jt_industry

keep if _merge==3

drop industrycode _merge SeriesID

save separations_by_type_JOLTS, replace

*For each data type generate 
local datatypes TS LD QU

foreach value of local datatypes{
	use separations_by_type_JOLTS, clear
	
	keep if data_element=="`value'"
	
	drop data_element 
	
	ds industrydescription, not
	
	rename (`r(varlist)') `value'=
	
	reshape long `value', i(industrydescription) j(MonthYear) string
	
	gen month = substr(MonthYear,1,3)

	gen year = substr(MonthYear,4,4)
	destring year, replace

	gen month1 = .

	local stringmonths= "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"

	local i =1

	foreach x of local stringmonths {
		replace month1= `i' if month=="`x'"
		local i = `i' +1	
		}
	
	drop month
	rename month1 month
	
	gen time= ym(year, month)
	
	format time %tm
	
	encode industrydescription, gen(industrycode)
	
	xtset industrycode time
	
	save "`value'_JOLTS", replace
	

}

use TS_JOLTS, clear
	
	twoway ///
	(line TS time if industrycode == 4, lcolor(green) lpattern(solid) lwidth(thin)) ///
	(line TS time if industrycode == 7, lcolor(black) lpattern(solid) lwidth(thin)) ///
    (line TS time if industrycode == 8, lcolor(orange) lpattern(solid) lwidth(thin)) ///
    (line TS time if industrycode == 9, lcolor(blue) lpattern(solid) lwidth(thick)) ///
	(line TS time if industrycode == 10, lcolor(gray) lpattern(solid) lwidth(thin)), ///
    legend(label(1 "Manufacturing") label(2 "Education & health") label(3 "Professional & business") label(4 "Total private")label(5 "Trade, transport, & utilities")size(small)) ///
	ytitle("Total Separations") xtitle("Year") ///
     xla(492(60)767, format(%tmCY)) ///
	
	graph export TS_JOLTS.jpg, replace
	
	

use LD_JOLTS, clear

twoway ///
	(line LD time if industrycode == 4, lcolor(green) lpattern(solid) lwidth(0.15)) ///
	(line LD time if industrycode == 7, lcolor(black) lpattern(solid) lwidth(0.15)) ///
    (line LD time if industrycode == 8, lcolor(orange) lpattern(solid) lwidth(0.15)) ///
    (line LD time if industrycode == 9, lcolor(blue) lpattern(solid) lwidth(0.5)) ///
	(line LD time if industrycode == 10, lcolor(gray) lpattern(solid) lwidth(0.15)), ///
    legend(label(1 "Manufacturing") label(2 "Education & health") label(3 "Professional & business") label(4 "Total private")label(5 "Trade, transport, & utilities") size(small)) ///
	ytitle("Layoffs and Discharges (%)") xtitle("Year") ///
     xla(492(60)767, format(%tmCY)) ///
	
	graph export LD_JOLTS.jpg, replace


