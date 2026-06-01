*Calls FRED data for Bayesian estimation

global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"


/* 1) Setup */
clear all
set more off

* >>> Put your FRED API key here <<<
global FREDKEY "86ca2054830db99b418a9a75dbe6000e"

* Date range (edit as needed)
local start "1950-01-01"
local stop  "2100-01-01"

import fred FEDFUNDS UNRATE JTSQUR JTSHIR JTSJOR JTSTSR CPIAUCSL A191RL1Q225SBEA GDPC1 AHETPI W825RC1 , aggregate (quarterly) daterange(`start' `stop') clear

gen qdate = qofd(daten)  

gen qdate_str = string(year(dofq(qdate))) + "q" + string(quarter(dofq(qdate)))

drop qdate  

cd "$mypath/Data/Clean"

export excel using "fred_series_bayesian.xlsx", firstrow(variables) replace
