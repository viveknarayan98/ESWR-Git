**Set directory
global mypath "/Users/viveknarayan/Library/Mobile Documents/com~apple~CloudDocs/vivek_camilo_project Rob Chen/Programs/ESWR-Git"
cd "${mypath}/Data/Clean"

*There are three specifications that we consider- job changer most restrictive, job changer less restrictive, job changer no restrictions. The first one is defined by people that only respond to empsame saying no. The problem with this is that it only applies from 1994 onwards and only works for mish 6-8 (we do not observe empsame in mish 5). The less restrictive case refers to people that change either industry_g (LineCode) or occ_g at any point of time. This proves to be a good proxy for not in universe responses to 


**Keep required variables
use year month cpsidp LineCode l_status mish empsame lnwage ind1990 unionm unionc educ nWhite age sex earnwt hours gradeate occ_g marst hours statefip using fullcps, clear

keep if inrange(age, 25, 55)

**Set panel
gen time = ym(year, month)
format time %tm
sort cpsidp time
tsset cpsidp time
tsset cpsidp time

**Define separations
gen EU12 = 0 if L12.l_status==1 & l_status!=.
replace EU12 = 1 if EU12==0 & (l_status==2 | L.l_status==2 | L2.l_status==2 | L3.l_status==2)  & (l_status!=3 & L.l_status!=3 & L2.l_status!=3 & L3.l_status!=3)


gen EN12 = 0 if L12.l_status==1 & l_status!=.
replace EN12 = 1 if EN12==0 & (l_status==3 | L.l_status==3 | L2.l_status==3 | L3.l_status==3)  & (l_status!=2 & L.l_status!=2 & L2.l_status!=2 & L3.l_status!=2)

gen ENE12 = 0 if L12.l_status==1 & l_status!=.
replace ENE12 = 1 if ENE12==0 & (l_status==2 | L.l_status==2 | L2.l_status==2 | L3.l_status==2 | l_status==3 | L.l_status==3 | L2.l_status==3 | L3.l_status==3) 




*Keep only the wage observations in labor force
keep if mish==4|mish==8
keep if l_status!=3

**Sets diff education levels

*HS Grad*
gen educationlevel= 2 if educ==73

*HS Dropout*
replace educationlevel=1 if educ<73

*Some College*
replace educationlevel=3 if inrange(educ, 81, 92)

*College Grad*
replace educationlevel=4 if educ==111

*Postgrad*
replace educationlevel=5 if educ>111

**Generating wage
*gen lnwage_WINDOW= timecoef_MINwindow+ constantcoef_MINwindow + w_MINwindow 
*gen lnwage_WHOLE= timecoef_MINwhole+ constantcoef_MINwhole + w_MINwhole

**Merging with CPS figures


merge m:1 year LineCode using merged_cps_annual

keep if _merge==3

drop _merge EE EU EN UE NE empdenom wage Employment EmploymentCPS male thours


*Create dummy var for male*
gen male=1 if sex==1
replace male=0 if sex==2

*Creates dummy for either covered or member of union*

gen unionmorc=1 if unionm==1|unionc==1
replace unionmorc=0 if unionm==0 & unionc==0

*Create variables for unemployment, leaving labor force, and not working (leaving and unemployment combined) 
sort cpsidp time 

gen f12unemployed= F12.EU12
gen f12leftlf= F12.EN12
gen f12notworking=F12.ENE12

*ssc install egenmore, replace

*egen quint= xtile(lnwage), n(5) by(time)

save fullcps_microreg, replace

*Execute micro regression*
*Age and gradeate?

egen clustergroup = group(statefip LineCode)

/*

*Baseline specification
logit f12unemployed lnwage age i.educationlevel i.year i.statefip GDP_G nWhite male lprod wrigid F12.lprice lprice [iw=earnwt], cluster(clustergroup)

*Robustness 1: COVID
preserve
keep if year <=2019
logit f12unemployed lnwage age i.educationlevel i.year i.statefip GDP_G nWhite male lprod wrigid F12.lprice lprice [iw=earnwt], cluster(clustergroup)
restore

*Robustness 2: Experience + Unionc

gen exp = age - gradeate - 6
logit f12unemployed lnwage age exp i.educationlevel i.year i.statefip GDP_G nWhite unionc male lprod wrigid F12.lprice lprice [iw=earnwt], cluster(clustergroup)

*Robustness 3: Cluster to statefip
logit f12unemployed lnwage age exp i.educationlevel i.year i.statefip GDP_G nWhite unionc male lprod wrigid F12.lprice lprice [iw=earnwt], cluster(clustergroup)

*Robustness 4: LineCode FE
logit f12unemployed age exp i.educationlevel i.year i.statefip i.LineCode GDP_G nWhite unionc male lprod lnwage wrigid F12.lprice lprice [iw=earnwt], cluster(clustergroup)

*/



*logit f12unemployed age i.occ_g i.educationlevel i.year i.LineCode GDP_G nWhite male lprod wrigid F12.lprice lnwage [iw=earnwt], cluster(clustergroup)

cap drop potexp
gen potexp = age - gradeate - 6
label var potexp "Potential experience"

*-----------------------------------------------------------------------------
* 1. MACROS
*-----------------------------------------------------------------------------

local dv     f12unemployed
local target lnwage lprod wrigid F12.lprice lprice

local base   age i.educationlevel i.year i.statefip GDP_G nWhite male
local ext    age potexp i.educationlevel i.year i.statefip GDP_G nWhite unionc male

local econ   lprod wrigid F12.lprice lprice

*-----------------------------------------------------------------------------
* 2. ESTIMATION
*-----------------------------------------------------------------------------

* --- Model 1: Baseline -------------------------------------------------------
logit `dv' lnwage `base' `econ' [iw=earnwt], cluster(clustergroup)
estimates store m1
estimates title: "1. Baseline"

* --- Model 2: Pre-COVID (year <= 2019) ---------------------------------------
preserve
    keep if year <= 2019
    logit `dv' lnwage `base' `econ' [iw=earnwt], cluster(clustergroup)
    estimates store m2
    estimates title: "2. Pre-COVID"
restore

* --- Model 3: + experience and union ----------------------------------------
logit `dv' lnwage `ext' `econ' [iw=earnwt], cluster(clustergroup)
estimates store m3
estimates title: "3. Experience + union"

* --- Model 4: cluster on statefip -------------------------------------------
* (your original had cluster(clustergroup) here -- corrected to statefip,
*  which is what the comment said you wanted)
logit `dv' lnwage `ext' `econ' [iw=earnwt], cluster(statefip)
estimates store m4
estimates title: "4. Cluster: statefip"

* --- Model 5: + LineCode fixed effects ---------------------------------------
logit `dv' lnwage `ext' i.LineCode `econ' [iw=earnwt], cluster(clustergroup)
estimates store m5
estimates title: "5. LineCode FE"

*-----------------------------------------------------------------------------
* 3. HARVEST b / se / z / p  (dependency-free)
*-----------------------------------------------------------------------------

tempname pf
tempfile res
postfile `pf' str24 model str16 term double(b se z p) using "`res'", replace

local mnames `" "1. Baseline" "2. Pre-COVID" "3. Exper+union" "4. Clus statefip" "5. LineCode FE" "'
local i = 0

foreach m in m1 m2 m3 m4 m5 {
    local ++i
    local mn : word `i' of `mnames'
    estimates restore `m'

    foreach v of local target {
        local bb = .
        local ss = .
        capture {
            local bb = _b[`v']
            local ss = _se[`v']
        }
        * a dropped / collinear term returns se == 0
        if _rc | missing(`ss') | `ss' <= 0 {
            post `pf' ("`mn'") ("`v'") (.) (.) (.) (.)
        }
        else {
            local zz = `bb'/`ss'
            local pp = 2*normal(-abs(`zz'))
            post `pf' ("`mn'") ("`v'") (`bb') (`ss') (`zz') (`pp')
        }
    }
}
postclose `pf'

*-----------------------------------------------------------------------------
* 4. DISPLAY AND EXPORT
*-----------------------------------------------------------------------------

preserve
    use "`res'", clear

    gen stars = cond(p < .01, "***", cond(p < .05, "**", cond(p < .10, "*", "")))
    format b se z %9.4f
    format p %9.3f

    list model term b se z p stars, sepby(model) noobs abbrev(16)

    export delimited using "wage_rigidity_coefs.csv", replace
    save "wage_rigidity_coefs.dta", replace
restore

di as txt _n "Saved: wage_rigidity_coefs.csv / .dta"

*-----------------------------------------------------------------------------
* 5. OPTIONAL: publication table via estout  (ssc install estout)
*-----------------------------------------------------------------------------

esttab m1 m2 m3 m4 m5 using "wage_rigidity_table.rtf", replace ///
    keep(lnwage lprod wrigid F12.lprice lprice)                ///
    order(lnwage lprod wrigid F12.lprice lprice)               ///
    b(%9.4f) se(%9.4f) p(%9.3f)                                ///
    star(* 0.10 ** 0.05 *** 0.01)                              ///
    stats(N ll, fmt(%9.0g %9.2f) labels("Observations" "Log-likelihood")) ///
    mtitles("Baseline" "Pre-COVID" "Exper+union" "Clus statefip" "LineCode FE") ///
    title("Determinants of unemployment 12 months ahead") ///
    nonotes addnotes("Logit coefficients. SEs in parentheses.")
	
	
	
	esttab m1 m2 m3 m4 m5 using "micro_reg_table.tex", replace ///
    keep(lnwage lprod wrigid F12.lprice lprice)                ///
    order(lnwage lprod wrigid F12.lprice lprice)               ///
    varlabels(lnwage "Log nominal wage" lprod "Log productivity" ///
              wrigid "Wage rigidity" F12.lprice "Log price (t+12)" ///
              lprice "Log price")                              ///
    b(4) se(4) star(* 0.10 ** 0.05 *** 0.01)                   ///
    stats(N r2_p, fmt(%9.0fc 3) labels("Observations" "Pseudo \$R^2\$")) ///
    mtitles("Baseline" "Pre-COVID" "Exper+union" "Clus statefip" "LineCode FE") ///
    title("Determinants of unemployment 12 months ahead\label{tab:wagerigid}") ///
    booktabs nonumbers nonotes label ///
    addnotes("Logit coefficients. Standard errors in parentheses." ///
             "* \$p<0.10\$, ** \$p<0.05\$, *** \$p<0.01\$." ///
             "Baseline (column 1) estimated on `=e(N)' observations.")

