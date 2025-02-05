global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen"

cd "${mypath}/Programs/2024 Programs"
*Create crosswalk between industry categories and ind1990 variable from CPS
	do ind1990_LCxwalk_annual_VN(24).do


cd "${mypath}/Programs/2024 Programs"
*Annual sectoral inflation measures
	do LoadAnnualInflation_VN(24).do


cd "${mypath}/Programs/2024 Programs"
*Annual sectoral GDP measures
	do LoadAnnualGDP_VN(24).do


cd "${mypath}/Programs/2024 Programs"
*Annual sectoral employment and merges with GDP and inflation
	do BLS_Annual_Employment_VN(24).do 


cd "${mypath}/Programs/2024 Programs"
*Creates the CPS microdata file for 1993-2004
	do fullcpsbuilder9304.do


cd "${mypath}/Programs/2024 Programs"
*Replaces earnings data with MORG data for 1979-1981
	do MergesMORG_VN(24).do


cd "${mypath}/Programs/2024 Programs"
*Creates the CPS microdata file for 1979-1992
	do fullcpsbuilder7992_VN(24).do


cd "${mypath}/Programs/2024 Programs"
*Creates the CPS microdata file for 2005-2024
	do Creatingfullcps05_VN(24).do


cd "${mypath}/Programs/2024 Programs"
*Builds out necessary binary variables and other controls for mincer equation
	do Microdataprep_VN(24).do


cd "${mypath}/Programs/2024 Programs"
*Imputes topcoded wages
	do Imputewages_VN(24).do



cd "${mypath}/Programs/2024 Programs"
*Collapses separations, demographics, wage changes, wage levels, etc by year and sector and merges with macro data
	do collapses_cps_annual_VN(24).do


cd "${mypath}/Programs/2024 Programs"
*Runs the micro model
	do Execute_Micro_Regression.do


cd "${mypath}/Programs/2024 Programs"
*Runs the macro model
	do Execute_Macro_Regression_VN(24).do






