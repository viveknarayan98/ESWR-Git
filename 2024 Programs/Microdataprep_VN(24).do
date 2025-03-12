
clear all
cls
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"
cd "${mypath}/Data/Clean"

*-----------------------------------------------------------------------
* Load data (load the full cps file that you want from the clean directory)
*-----------------------------------------------------------------------

*local yearrange 0523
*local filename fullcps`yearrange'


	use fullcps0523, clear
	append using fullcps9304
	append using fullcps7992
	
	qui summarize year
	local iyear = r(min)
	local lyear = r(max)

*-----------------------------------------------------------------------
* create hours variable
*-----------------------------------------------------------------------
	gen hours= uhrsworkorg if uhrsworkorg<998
	replace hours= uhrswork1 if hours==. & numjob<2 & uhrswork1<997 & uhrswork1!=.
	
	*CPS tells us ahrsworkt needs to be used with empstat
	replace hours= ahrsworkt if hours==. & ahrsworkt!=999 & empstat==10
	replace hours=. if mish!=4 & mish!=8
	
	if `iyear'==1979{
		replace hours= hourslw_morg if year<= 1981
		replace hours= uhrswork1 if hours==. & uhrswork1<997 & inrange(year,1982, 1988)
	}
	
	replace hours = . if hours<5 | hours>80

*-----------------------------------------------------------------------
* Clear earnings
*-----------------------------------------------------------------------
    if `iyear'==1979{
		replace earnweek= earnwke_morg if year<=1981
		replace earnwt = earnwt_morg if year<=1981
	}
	gen earnweek_o = earnweek
	replace earnweek = . if earnweek>=9999 | earnweek<=0

*-----------------------------------------------------------------------
* Clean age
*-----------------------------------------------------------------------
	replace age = . if age<=0 | age >=80

*-----------------------------------------------------------------------
* Race dummy
*-----------------------------------------------------------------------
	gen nWhite = 1 if race <990 & race!=.
	replace nWhite = 0 if race==100

*-----------------------------------------------------------------------
* Married dummy	
* married=1 married, = 0 otherwise
*-----------------------------------------------------------------------
	gen married = 0
	replace married = 1 if marst == 1 | marst == 2
	replace married = . if marst == 9
	
	
*-----------------------------------------------------------------------
*Union variables (union=2: member; union=3: covered but not a member)
*-----------------------------------------------------------------------
	gen unionm = 0
	gen unionc = 0
	replace unionm = 1 if union == 2
	replace unionc = 1 if union == 3


*-----------------------------------------------------------------------
* Class of worker (=1 wage priv, =2 wage public, =3 self, = . other)
*-----------------------------------------------------------------------
	gen class_worker = .
	replace class_worker = 1 if classwkr >= 21 & classwkr <= 23 & classwkr != .
	replace class_worker = 2 if classwkr >= 24 & classwkr <= 28 & classwkr != .
	replace class_worker = 3 if classwkr >= 10 & classwkr <= 14 & classwkr != .

*-----------------------------------------------------------------------
*Education variables
*-----------------------------------------------------------------------
	gen gradeate=0		
	replace gradeate=2.5  if educ>=010 & educ<=14 & educ!=. 
	replace gradeate=5.5  if educ>=020 & educ<=22 & educ!=.  
	replace gradeate=7.5  if educ>=030 & educ<=32 & educ!=. 
	replace gradeate=9    if educ==040
	replace gradeate=10   if educ==050 
	replace gradeate=11   if educ==060
	replace gradeate=12   if educ>=070 & educ<=073 & educ!=.
	replace gradeate=13   if educ==080 | educ==081 
	replace gradeate=14   if educ>=090 & educ<=092 & educ!=.
	replace gradeate=15   if educ==100 
	replace gradeate=16   if educ>=110 & educ<=111 & educ!=.
	replace gradeate=17   if educ>=120 & educ<=122 & educ!=.
	replace gradeate=18   if educ>=123 | educ==124 | educ==125
	replace gradeate=.    if educ==001 | educ>=990
	
*-----------------------------------------------------------------------	
* New occ codes for 1990
*-----------------------------------------------------------------------
	gen occ_g = .
	
	* Management
	replace occ_g = 1 if occ1990>=000 & occ1990<=037 & occ1990!=.
	
	* Professional Specialty
	replace occ_g = 2 if occ1990>=43 & occ1990<=199 & occ1990!=.
	
	* Technical 
	replace occ_g = 3 if occ1990>=203 & occ1990<=235 & occ1990!=.
	
	* Sales
	replace occ_g = 4 if occ1990>=243 & occ1990<=290 & occ1990!=.
	
	* Clerical and Support
	replace occ_g = 5 if occ1990>=303 & occ1990<=391 & occ1990!=.
	
	* Service
	replace occ_g = 6 if occ1990>=403 & occ1990<=469 & occ1990!=.
	
	* Farmer, Fishing, and Forestry
	replace occ_g = 7 if occ1990>=473 & occ1990<=499 & occ1990!=.
	
	* Construction and Mechanics
	replace occ_g = 8 if occ1990>=503 & occ1990<=617 & occ1990!=.
	
	* Precision Production
	replace occ_g = 9 if occ1990>=628 & occ1990<=699 & occ1990!=.
	
	* Operators and Laborers
	replace occ_g = 10 if (occ1990>=703 & occ1990<=799 & occ1990!=.) | (occ1990>=843 & occ1990<=890 & occ1990!=.)
	
	* Transportation
	replace occ_g = 11 if occ1990>=803 & occ1990<=834 & occ1990!=.	
	
	*Military
	replace occ_g = 12 if occ1990>=903 & occ1990<=905 & occ1990!=.

*-----------------------------------------------------------------------	
* Industry Codes
*-----------------------------------------------------------------------
	gen ind_g = .

	* Agriculture, Forestry, and Fisheries
	replace ind_g = 1 if ind1990>=000 & ind1990<=032 & ind1990!=.
	
	* Mining and Construction
	replace ind_g = 2 if ind1990>=40 & ind1990<=60 & ind1990!=.
	
	* Nondurable Goods Manufacturing 
	replace ind_g = 3 if ind1990>=100 & ind1990<=229 & ind1990!=.
	
	* Durable Goods Manufacturing
	replace ind_g = 4 if ind1990>=230 & ind1990<=392 & ind1990!=.
	
	* Transportation, Communication, and Utilities
	replace ind_g = 5 if ind1990>=400 & ind1990<=472 & ind1990!=.
	
	* Wholesale Trade
	replace ind_g = 6 if ind1990>=500 & ind1990<=571 & ind1990!=.
	
	* Retail Trade
	replace ind_g = 7 if ind1990>=580 & ind1990<=691 & ind1990!=.
	
	* Services
	replace ind_g = 8 if ind1990>=700 & ind1990<=893 & ind1990!=.
	
	* Public Admin and Military
	replace ind_g = 9 if ind1990>=900 & ind1990<=960 & ind1990!=.

*-----------------------------------------------------------------------	
* generate labor force status
*-----------------------------------------------------------------------
	gen l_status = .
	replace l_status = 1 if empstat == 10 | empstat == 12
	replace l_status = 2 if empstat >= 20 & empstat <= 22 & empstat !=.
	replace l_status = 3 if empstat >= 30 & empstat !=.
	
*-----------------------------------------------------------------------
* Experience
*-----------------------------------------------------------------------
	gen exp = age - gradeate - 6
	gen exp2 = exp*exp
	gen exp3 = exp2*exp
	gen exp4 = exp3*exp
	

*-----------------------------------------------------------------------	
* Save file (resave it as whatever filename you wanted at the beginning)
*-----------------------------------------------------------------------
save fullcps, replace 

erase fullcps9304.dta 
erase fullcps7992.dta



