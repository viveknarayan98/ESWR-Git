*Clear directory 

clear all
cls

**Set directory
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"
cd "${mypath}/Data/Clean"
*Use 2005-2023 dataset
use fullcps0523mincer, clear

append using fullcps7992mincer

append using fullcps9304mincer

keep if inrange(age, 25, 55)

keep year month cpsidp w_MINwindow l_status mish earnwt hours wtfinl

gen w_MINwindow_rounded = round(w_MINwindow, 0.01)

collapse(mean) mean_unemployment = f12unemployed (count) count_workers = f12unemployed (semean) se_unemployment = f12unemployed [aw=earnwt*hours], by(w_MINwindow_rounded)

keep if inrange(w_MINwindow_rounded, -1.1, 1.1)

gen lower_ci = mean_unemployment - invttail(_N-1, 0.025) * se_unemployment

gen upper_ci = mean_unemployment + invttail(_N-1, 0.025) * se_unemployment

twoway (qfitci mean_unemployment w_MINwindow_rounded)

graph export "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Data/Clean/Unemployment_Mincer.jpg", as(jpg) name("Graph") quality(100)
