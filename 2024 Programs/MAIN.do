global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"


**MACRO DATA**

*ANNUAL SERIES*

	cd "${mypath}/2024 Programs"
	*Annual sectoral GDP measures
	do "LoadAnnualGDP_VN(24).do"
	
	cd "${mypath}/2024 Programs"
	*Annual sectoral inflation measures
	do "BuildInflationIndex.do"
	
*QUARTERLY SERIES*

	cd "${mypath}/Programs/2024 Programs"
	*Creates quarterly GDP nominal and real GDP series
	do "Cleaningstategdp_VN(24).do" 

	cd "${mypath}/Programs/2024 Programs"
	*Categorizes industries to Line Codes
	do "Cleansindustrydata_VN(24).do"
	
	cd "${mypath}/Programs/2024 Programs"
	*Creates quarterly employment series based on SAE series from BLS
	do "ParsesSeriesID_VN(24).do"
	

*CROSSWALK*

	cd "${mypath}/2024 Programs"
	*Create crosswalk between industry categories and ind1990 variable from CPS
	do "ind1990_LCxwalk_VN(24).do"


**MICRO DATA**

*Constructs microdata downloaded from IPUMS in 3 batches- 1979-1992, 1993-2004, 2005-2023

	*1979-1992

	cd "${mypath}/2024 Programs"
	*Replaces earnings data with MORG data for 1979-1981
	do "MergesMORG_VN(24).do"

	
	cd "${mypath}/2024 Programs"
	*Creates the CPS microdata file for 1979-1992
	do "fullcpsbuilder7992_VN(24).do"
	
	cd "${mypath}/2024 Programs"
	*Creates the CPS microdata file for 1993-2004
	do "fullcpsbuilder9304.do"

	
	*2005-2023
	cd "${mypath}/2024 Programs"
	*Creates the CPS microdata file for 2005-2024
	do "Creatingfullcps05_VN(24).do"
	
*Variable construction

	cd "${mypath}/2024 Programs"
	*Builds out necessary binary variables and other controls for mincer equation
	do "Microdataprep_VN(24).do"


	cd "${mypath}/2024 Programs"
	*Imputes topcoded wages
	do "Imputewages_VN(24).do"

	
	
**COLLAPSING DATA FOR MODEL WORK**

	cd "${mypath}/Programs/2024 Programs"
	*Collapses CPS to prepare for quarterly macro regressions
	do "collapsescps_quarterly_VN(26)".do

	cd "${mypath}/Programs/2024 Programs"
	*Collapses CPS to prepare for annual macro regressions
	do "collapsescps_annual_VN(24)".do
	
*Micro regression

	cd "${mypath}/2024 Programs"
	*Runs the micro model
	do "Execute_Micro_Regression_VN(24).do"
	
*Macro regression

	cd "${mypath}/2024 Programs"
	*Runs the macro model (need to set quarterly to either 1 or 0 depending on which regression you want to run)
	do "Execute_Macro_Regression_VN(24).do"
	
