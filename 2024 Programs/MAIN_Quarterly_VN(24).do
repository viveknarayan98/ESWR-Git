global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

*We run two variations of the macro regression. One is for the range of years where we have access to quarterly macroeconomic data (2005-2023) and the other is with annual macroeconomic data (1979-2023). This do file applies to the former. 

cd "${mypath}/Programs/2024 Programs"

*Creates quarterly GDP nominal and real GDP series
	do Cleaningstategdp_VN(24).do 

cd "${mypath}/Programs/2024 Programs"

*Categorizes industries to Line Codes
	do Cleansindustrydata_VN(24).do

cd "${mypath}/Programs/2024 Programs"

*Creates crosswalk between ind1990 from CPS and 
	do ind1990_LCxwalk_VN(24).do

cd "${mypath}/Programs/2024 Programs"
	
*Creates quarterly employment series based on SAE series from BLS
	do ParsesSeriesID_VN(24).do

cd "${mypath}/Programs/2024 Programs"

*Builds 2005 onwards microdata
	do Creatingfullcps05_VN(24).do

cd "${mypath}/Programs/2024 Programs"

*Creates control variables and wage variables that will be used in model
	do Microdataprep_VN(24).do

cd "${mypath}/Programs/2024 Programs"

*Imputes top coded wages
	do Imputewages_VN(24).do

cd "${mypath}/Programs/2024 Programs"

*Collapses CPS to prepare for macro regressions
	do collapsescps_VN(24).do

cd "${mypath}/Programs/2024 Programs"

*Execute macro regressions
	do Execute_Macro_Regression_VN(24).do
	


