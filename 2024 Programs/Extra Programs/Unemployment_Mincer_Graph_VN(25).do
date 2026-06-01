*Clear directory 

clear all
cls

**Set directory
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Data/Clean"

*Use 2005-2023 dataset
/*
use fullcps0523mincer, clear

append using fullcps7992mincer

append using fullcps9304mincer

keep if inrange(age, 25, 55)

gen time = ym(year, month)
format time %tm
sort cpsidp time
tsset cpsidp time
tsset cpsidp time

gen EU12 = 0 if L12.l_status==1 & l_status!=.
replace EU12 = 1 if EU12==0 & (l_status==2 | L.l_status==2 | L2.l_status==2 | L3.l_status==2)  & (l_status!=3 & L.l_status!=3 & L2.l_status!=3 & L3.l_status!

gen f12unemployed= F12.EU12

keep year month cpsidp w_MINwindow l_status mish earnwt hours wtfinl f12unemployed

gen w_MINwindow_rounded = round(w_MINwindow, 0.01)

save fullcps_mincer_unemployment, replace
*/

use fullcps_mincer_unemployment, clear

*Collapse unemployment by mincer residual
collapse(mean) mean_unemployment = f12unemployed (count) count_workers = f12unemployed (semean) se_unemployment = f12unemployed [aw=earnwt*hours], by(w_MINwindow_rounded)

*Keeping within a smaller band
keep if inrange(w_MINwindow_rounded, -1.1, 1.1)

gen lower_ci = mean_unemployment - invttail(_N-1, 0.025) * se_unemployment

gen upper_ci = mean_unemployment + invttail(_N-1, 0.025) * se_unemployment


*Create graph
twoway ///
    (scatter mean_unemployment w_MINwindow_rounded, mcolor(gs8)) ///
    (lowess mean_unemployment w_MINwindow_rounded, lcolor(blue) lwidth(medium)), ///
    ytitle("Mean 12-month unemployment rate") ///
    xtitle("Mincer residual") ///
    legend(off)

twoway (qfitci mean_unemployment w_MINwindow_rounded)

graph export "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Data/Clean/Unemployment_Mincer.jpg", replace as(jpg) name("Graph") quality(100)


