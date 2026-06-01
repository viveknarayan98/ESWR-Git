clear
set more off
***************************************************************************
* Specify your directory names; the rest works equally in Windows and Mac *
***************************************************************************
// Example for the Mac directory format
global bases="/Users/c1sxf11/Library/CloudStorage/OneDrive-FRBanks/E2EReplication"
global dos="$bases/Stata/Imputation"			    // folder for do files for imputation steps
global raw="$bases/CPSData/CPSMonthly-Raw"  	    // folder for the unzipped raw data (unzip CPSMonthly-Raw)
global dta="$bases/CPSData/DTA"						// folder for all new files are saved 

// Example for the Windows directory format

// global bases="C:\Users\c1sxf11\OneDrive - FR Banks\E2EReplication" 						// root directory
// global dos="$bases\Stata\Imputation"		// directory for imputation step
// global raw="$bases\CPSData\CPSMonthly-Raw"			// directory where raw data has been unzipped
// global dta="$bases\CPSData\DTA"					// directory where new Stata files are saved


*
local filelist 1_extract 2_1_adjust_ind  2_2_adjust_occ   3_match 4_genvars_Probit  5_append_matched 6_genvars_matched 7_UEr_JJrSS_append 8_imputation_base

foreach filename of local filelist {
cd "$dos"
do "`filename'.do"'	
}

