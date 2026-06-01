
**********************************************************
*To run this code, you have to unzip the file CPSMonthly-Raw.zip
**********************************************************

clear

set more off

local x=199401

cd "$dta"

**********************************************
****************** Dictionary ****************
**********************************************
while `x' <=199508 {
clear
local year=round(`x'/100)
local month=round((`x'-`year'*100))
quietly infix str hrhhid 1-12 hrmonth 65-66 gemsast 108-109 geindvcc 110-111 gemetsta 112-113 hryear 67-68 str hrsample 71-74 str hrsersuf 75-76 huhhnum 77-78 gestcen 91-92 pulineno 147-148 hrmis 63-64 /// 
perrp 118-119 peage 122-123 pemaritl 125-126 pesex 129-130 peeduca 137-138 perace 139-140 puslfprx 178-179  pemlr 180-181 puretot 196-197 pudis 198-199 pehrusl1 218-219 pehrftpt 222-223 pehrwant 227-228  prsjms 496-497 /// 
prunedur  407-409 pruntype 412-413 prwkstat 416-417 puiodp1 426-427 puiodp2 428-429 puiodp3 430-431 peioicd 436-438 prabsrea 385-386 prdtcow 468-469 peioocd 439-441 prmjind1 482-483 prmjocc1 486-487 prcow1 462-463 double pwlgwgt 593-602 double  pwsswgt 613-622 ///
using "$raw/cpsb`x'"

*recode pemlr (5/7=5) 
*Just lump together 5-7 in pelmr as 5 to be consistent with previous years.

*recode pruntype (1=1) (2/3=2) (4=3) (5/6=4)
*New category "temp job ended" is created in this period and I am lumping this together with job losers (category 2 and call them 2)

recode pemaritl (1=1) (2 5 = 2) (3/4=3) (6=4)
*After recoding:
*1 = Married spouse present
*2 = Married spouse absent or separated
*3 = Widowed/divorced
*4 = Never married   

recode peeduca (31/38=1) (39=2) (40/42=3) (43=4) (44/46=5)
*After recoding:
*1 = less than high school
*2 = high school
*3 = some college 
*4 = college
*5 = graduate degree   



replace pwsswgt = 0 if peage < 16
rename  pwsswgt fweight
replace fweight = fweight/100

sort hrhhid hrsample pulineno perace pesex peage hrmis

gen year = int(`x'/100)
gen month = `x'-year*100


replace hrsersuf="00" if hrsersuf=="-1"
replace hrsersuf="01" if hrsersuf=="A"
replace hrsersuf="02" if hrsersuf=="B"
replace hrsersuf="03" if hrsersuf=="C"
replace hrsersuf="04" if hrsersuf=="D"
replace hrsersuf="05" if hrsersuf=="E"
replace hrsersuf="06" if hrsersuf=="F"
replace hrsersuf="07" if hrsersuf=="G"
replace hrsersuf="08" if hrsersuf=="H"
replace hrsersuf="09" if hrsersuf=="I"
replace hrsersuf="10" if hrsersuf=="J"
replace hrsersuf="11" if hrsersuf=="K"
replace hrsersuf="12" if hrsersuf=="L"
replace hrsersuf="13" if hrsersuf=="M"
replace hrsersuf="14" if hrsersuf=="N"
replace hrsersuf="15" if hrsersuf=="O"
replace hrsersuf="16" if hrsersuf=="P"
replace hrsersuf="17" if hrsersuf=="Q"
replace hrsersuf="18" if hrsersuf=="R"
replace hrsersuf="19" if hrsersuf=="S"
replace hrsersuf="20" if hrsersuf=="T"
replace hrsersuf="21" if hrsersuf=="U"
replace hrsersuf="22" if hrsersuf=="V"
replace hrsersuf="23" if hrsersuf=="W"
replace hrsersuf="24" if hrsersuf=="X"
replace hrsersuf="25" if hrsersuf=="Y"
replace hrsersuf="26" if hrsersuf=="Z"

gen hsample = substr(hrsample,2,2)
egen hrhhid2 = concat(hsample hrsersuf huhhnum)

compress
save cpsm`x'.dta, replace

local x = `x' + 1
if (`x'-13)/100 == int((`x'-13)/100) {
    local x = `x' + 88
    }
}


while `x' <=199712{
clear
local year=round(`x'/100)
local month=round((`x'-`year'*100))
quietly infix str hrhhid 1-15 hrmonth 65-66 hryear 67-68 str hrsample 71-74 str hrsersuf 75-76 huhhnum 77-78 gestcen 91-92 pulineno 147-148 hrmis 63-64 perrp 118-119 peage 122-123 pemaritl 125-126 /// 
pesex 129-130 peeduca 137-138 perace 139-140 puslfprx 178-179   pemlr 180-181 puretot 196-197 pudis 198-199 pehrusl1 218-219 pehrftpt 222-223 pehrwant 227-228 prunedur 407-409 pruntype 412-413 prwkstat 416-417 puiodp1 426-427 puiodp2 428-429 puiodp3 430-431  prabsrea 385-386 prdtcow 468-469   prsjms 496-497 ///
peioicd 436-438 peioocd 439-441 prmjind1 482-483 prmjocc1 486-487 prcow1 462-463 double pwlgwgt 593-602 double pwsswgt 613-622 ///
using "$raw/cpsb`x'"

*recode pemlr (5/7=5) 
*Just lump together 5-7 in pelmr as 5 to be consistent with previous years.

*recode pruntype (1=1) (2/3=2) (4=3) (5/6=4)
*New category "temp job ended" is created in this period and I am lumping this together with job losers (category 2 and call them 2)

recode pemaritl (1=1) (2 5 = 2) (3/4=3) (6=4)
*After recoding:
*1 = Married spouse present
*2 = Married spouse absent or separated
*3 = Widowed/divorced
*4 = Never married   

recode peeduca (31/38=1) (39=2) (40/42=3) (43=4) (44/46=5)
*After recoding:
*1 = less than high school
*2 = high school
*3 = some college 
*4 = college
*5 = graduate degree   

replace pwsswgt = 0 if peage < 16
rename  pwsswgt fweight
replace fweight = fweight/100


sort hrhhid hrsample pulineno perace pesex peage hrmis

gen year = int(`x'/100)
gen month = `x'-year*100

replace hrsersuf="00" if hrsersuf=="-1"
replace hrsersuf="01" if hrsersuf=="A"
replace hrsersuf="02" if hrsersuf=="B"
replace hrsersuf="03" if hrsersuf=="C"
replace hrsersuf="04" if hrsersuf=="D"
replace hrsersuf="05" if hrsersuf=="E"
replace hrsersuf="06" if hrsersuf=="F"
replace hrsersuf="07" if hrsersuf=="G"
replace hrsersuf="08" if hrsersuf=="H"
replace hrsersuf="09" if hrsersuf=="I"
replace hrsersuf="10" if hrsersuf=="J"
replace hrsersuf="11" if hrsersuf=="K"
replace hrsersuf="12" if hrsersuf=="L"
replace hrsersuf="13" if hrsersuf=="M"
replace hrsersuf="14" if hrsersuf=="N"
replace hrsersuf="15" if hrsersuf=="O"
replace hrsersuf="16" if hrsersuf=="P"
replace hrsersuf="17" if hrsersuf=="Q"
replace hrsersuf="18" if hrsersuf=="R"
replace hrsersuf="19" if hrsersuf=="S"
replace hrsersuf="20" if hrsersuf=="T"
replace hrsersuf="21" if hrsersuf=="U"
replace hrsersuf="22" if hrsersuf=="V"
replace hrsersuf="23" if hrsersuf=="W"
replace hrsersuf="24" if hrsersuf=="X"
replace hrsersuf="25" if hrsersuf=="Y"
replace hrsersuf="26" if hrsersuf=="Z"
gen hsample = substr(hrsample,2,2)
egen hrhhid2 = concat(hsample hrsersuf huhhnum)

compress
save cpsm`x'.dta, replace

local x = `x' + 1
if (`x'-13)/100 == int((`x'-13)/100) {
    local x = `x' + 88
    }
}


while `x' <=200212{
clear
local year=round(`x'/100)
local month=round((`x'-`year'*100))
quietly infix str hrhhid 1-15 hrmonth 16-17 hryear 18-21 str hrsample 71-74 str hrsersuf 75-76 huhhnum 77-78 gestcen 91-92 pulineno 147-148 hrmis 63-64 perrp 118-119 peage 122-123 pemaritl 125-126 /// 
pesex 129-130 peeduca 137-138 perace 139-140 puslfprx 178-179  pemlr 180-181 puretot 196-197 pudis 198-199 pehrusl1 218-219 pehrftpt 222-223 pehrwant 227-228 prunedur 407-409 pruntype 412-413 prwkstat 416-417 puiodp1 426-427 puiodp2 428-429 puiodp3 430-431 prabsrea 385-386 prdtcow 468-469    prsjms 496-497 ///
peioicd 436-438 peioocd 439-441 prmjind1 482-483 prmjocc1 486-487 prcow1 462-463 double pwlgwgt 593-602 double pwcmpwgt 846-855 ///
using "$raw/cpsb`x'"


*recode pemlr (5/7=5) 
*Just lump together 5-7 in pelmr as 5 to be consistent with previous years.

*recode pruntype (1=1) (2/3=2) (4=3) (5/6=4)
*New category "temp job ended" is created in this period and I am lumping this together with job losers (category 2 and call them 2)

recode pemaritl (1=1) (2 5 = 2) (3/4=3) (6=4)
*After recoding:
*1 = Married spouse present
*2 = Married spouse absent or separated
*3 = Widowed/divorced
*4 = Never married   

recode peeduca (31/38=1) (39=2) (40/42=3) (43=4) (44/46=5)
*After recoding:
*1 = less than high school
*2 = high school
*3 = some college 
*4 = college
*5 = graduate degree   

sort hrhhid hrsample pulineno perace pesex peage hrmis

replace pwcmpwgt = 0 if peage < 16
rename  pwcmpwgt fweight
replace fweight = fweight/100


sort hrhhid hrsample pulineno perace pesex peage hrmis


gen year = int(`x'/100)
gen month = `x'-year*100

replace hrsersuf="00" if hrsersuf=="-1"
replace hrsersuf="01" if hrsersuf=="A"
replace hrsersuf="02" if hrsersuf=="B"
replace hrsersuf="03" if hrsersuf=="C"
replace hrsersuf="04" if hrsersuf=="D"
replace hrsersuf="05" if hrsersuf=="E"
replace hrsersuf="06" if hrsersuf=="F"
replace hrsersuf="07" if hrsersuf=="G"
replace hrsersuf="08" if hrsersuf=="H"
replace hrsersuf="09" if hrsersuf=="I"
replace hrsersuf="10" if hrsersuf=="J"
replace hrsersuf="11" if hrsersuf=="K"
replace hrsersuf="12" if hrsersuf=="L"
replace hrsersuf="13" if hrsersuf=="M"
replace hrsersuf="14" if hrsersuf=="N"
replace hrsersuf="15" if hrsersuf=="O"
replace hrsersuf="16" if hrsersuf=="P"
replace hrsersuf="17" if hrsersuf=="Q"
replace hrsersuf="18" if hrsersuf=="R"
replace hrsersuf="19" if hrsersuf=="S"
replace hrsersuf="20" if hrsersuf=="T"
replace hrsersuf="21" if hrsersuf=="U"
replace hrsersuf="22" if hrsersuf=="V"
replace hrsersuf="23" if hrsersuf=="W"
replace hrsersuf="24" if hrsersuf=="X"
replace hrsersuf="25" if hrsersuf=="Y"
replace hrsersuf="26" if hrsersuf=="Z"
gen hsample = substr(hrsample,2,2)
egen hrhhid2 = concat(hsample hrsersuf huhhnum)

compress
save cpsm`x'.dta, replace

local x = `x' + 1
if (`x'-13)/100 == int((`x'-13)/100) {
    local x = `x' + 88
    }
}

while `x' <=200404{
clear
local year=round(`x'/100)
local month=round((`x'-`year'*100))
quietly infix str hrhhid 1-15 hrmonth 16-17 hryear 18-21 str hrsample 71-74 str hrsersuf 75-76 huhhnum 77-78 gestcen 91-92 pulineno 147-148 hrmis 63-64 perrp 118-119 peage 122-123 pemaritl 125-126 /// 
pesex 129-130 peeduca 137-138 perace 139-140 puslfprx 178-179  pemlr 180-181 puretot 196-197 pudis 198-199 pehrusl1 218-219 pehrftpt 222-223 pehrwant 227-228 prunedur 407-409 pruntype 412-413 prwkstat 416-417 puiodp1 426-427 puiodp2 428-429 puiodp3 430-431  prabsrea 385-386 prdtcow 468-469   prsjms 496-497 ///
prmjind1 482-483 prmjocc1 486-487 prcow1 462-463 double pwlgwgt 593-602 double pwcmpwgt 846-855 peioicd 856-859 peioocd 860-863 ///
using "$raw/cpsb`x'"

*recode pemlr (5/7=5) 
*Just lump together 5-7 in pelmr as 5 to be consistent with previous years.

recode pruntype (1=1) (2/3=2) (4=3) (5/6=4)
*New category "temp job ended" is created in this period and I am lumping this together with job losers (category 2 and call them 2)

recode pemaritl (1=1) (2 5 = 2) (3/4=3) (6=4)
*After recoding:
*1 = Married spouse present
*2 = Married spouse absent or separated
*3 = Widowed/divorced
*4 = Never married   

recode peeduca (31/38=1) (39=2) (40/42=3) (43=4) (44/46=5)
*After recoding:
*1 = less than high school
*2 = high school
*3 = some college 
*4 = college
*5 = graduate degree   

sort hrhhid hrsample pulineno perace pesex peage hrmis

replace pwcmpwgt = 0 if peage < 16
rename  pwcmpwgt fweight
replace fweight = fweight/100

gen year = int(`x'/100)
gen month = `x'-year*100

replace hrsersuf="00" if hrsersuf=="-1"
replace hrsersuf="01" if hrsersuf=="A"
replace hrsersuf="02" if hrsersuf=="B"
replace hrsersuf="03" if hrsersuf=="C"
replace hrsersuf="04" if hrsersuf=="D"
replace hrsersuf="05" if hrsersuf=="E"
replace hrsersuf="06" if hrsersuf=="F"
replace hrsersuf="07" if hrsersuf=="G"
replace hrsersuf="08" if hrsersuf=="H"
replace hrsersuf="09" if hrsersuf=="I"
replace hrsersuf="10" if hrsersuf=="J"
replace hrsersuf="11" if hrsersuf=="K"
replace hrsersuf="12" if hrsersuf=="L"
replace hrsersuf="13" if hrsersuf=="M"
replace hrsersuf="14" if hrsersuf=="N"
replace hrsersuf="15" if hrsersuf=="O"
replace hrsersuf="16" if hrsersuf=="P"
replace hrsersuf="17" if hrsersuf=="Q"
replace hrsersuf="18" if hrsersuf=="R"
replace hrsersuf="19" if hrsersuf=="S"
replace hrsersuf="20" if hrsersuf=="T"
replace hrsersuf="21" if hrsersuf=="U"
replace hrsersuf="22" if hrsersuf=="V"
replace hrsersuf="23" if hrsersuf=="W"
replace hrsersuf="24" if hrsersuf=="X"
replace hrsersuf="25" if hrsersuf=="Y"
replace hrsersuf="26" if hrsersuf=="Z"
gen hsample = substr(hrsample,2,2)
egen hrhhid2 = concat(hsample hrsersuf huhhnum)

compress

save cpsm`x'.dta, replace

local x = `x' + 1
if (`x'-13)/100 == int((`x'-13)/100) {
    local x = `x' + 88
    }
}

while `x' <=201312{
clear
local year=round(`x'/100)
local month=round((`x'-`year'*100))

quietly infix str hrhhid 1-15 hrhhid2 71-75 hrmonth 16-17 hryear 18-21 gestcen 91-92 pulineno 147-148 hrmis 63-64 perrp 118-119 peage 122-123 pemaritl 125-126 /// 
pesex 129-130 peeduca 137-138 perace 139-140 puslfprx 178-179  pemlr 180-181 puretot 196-197 pudis 198-199 pehrusl1 218-219 pehrftpt 222-223 pehrwant 227-228 prunedur 407-409 pruntype 412-413 prwkstat 416-417 puiodp1 426-427 puiodp2 428-429 puiodp3 430-431  prabsrea 385-386 prdtcow 468-469    prsjms 496-497 ///
prmjind1 482-483 prmjocc1 486-487 prcow1 462-463 double pwlgwgt 593-602 double pwcmpwgt 846-855 peioicd 856-859 peioocd 860-863  ///
using "$raw/cpsb`x'"

*recode pemlr (5/7=5) 
*Just lump together 5-7 in pelmr as 5 to be consistent with previous years.

*recode pruntype (1=1) (2/3=2) (4=3) (5/6=4)
*New category "temp job ended" is created in this period and I am lumping this together with job losers (category 2 and call them 2)

recode pemaritl (1=1) (2 5 = 2) (3/4=3) (6=4)
*After recoding:
*1 = Married spouse present
*2 = Married spouse absent or separated
*3 = Widowed/divorced
*4 = Never married   

recode peeduca (31/38=1) (39=2) (40/42=3) (43=4) (44/46=5)
*After recoding:
*1 = less than high school
*2 = high school
*3 = some college 
*4 = college
*5 = graduate degree   

sort hrhhid pulineno perace pesex peage hrmis

replace pwcmpwgt = 0 if peage < 16
*Probably pwcmpwgt is already zero for peage <16
rename  pwcmpwgt fweight
replace fweight = fweight/100

tostring hrhhid2, replace
*Before 200404, hrhhid2 is created as string but after that, hrhhid2 (which is already in the data) is float. 
*So I convert hrhhid2 into string. The other way around was tried but in very rare cases, huhhnum takes value -1 in pre-2004 data.
*This makes the destring command useless (destring is actually not carried out in the code). 


gen year = int(`x'/100)
gen month = `x'-year*100

compress
save cpsm`x'.dta, replace

local x = `x' + 1
if (`x'-13)/100 == int((`x'-13)/100) {
    local x = `x' + 88
    }
}


while `x' <=202212{
clear
local year=round(`x'/100)
local month=round((`x'-`year'*100))

quietly infix str hrhhid 1-15 hrhhid2 71-75 hrmonth 16-17 hryear 18-21 gestfips 93-94 pulineno 147-148 hrmis 63-64 perrp 118-119 peage 122-123 pemaritl 125-126 /// 
pesex 129-130 peeduca 137-138 perace 139-140 puslfprx 178-179  pemlr 180-181 puretot 196-197 pudis 198-199 pehrusl1 218-219 pehrftpt 222-223 pehrwant 227-228 prunedur 407-409 pruntype 412-413 prwkstat 416-417 puiodp1 426-427 puiodp2 428-429 puiodp3 430-431  prabsrea 385-386 prdtcow 468-469   prsjms 496-497 ///
prmjind1 482-483 prmjocc1 486-487 prcow1 462-463 double pwlgwgt 593-602 double pwcmpwgt 846-855 peioicd 856-859 peioocd 860-863  /// 
using "$raw/cpsb`x'"


*pulk 294-295 pelkm1 296-297 pulkdk1 308-309 ///


** Only difference is gestfips instead of gestcen (which is no longer avaialble)

*recode pemlr (5/7=5) 
*Just lump together 5-7 in pelmr as 5 to be consistent with previous years.

*recode pruntype (1=1) (2/3=2) (4=3) (5/6=4)
*New category "temp job ended" is created in this period and I am lumping this together with job losers (category 2 and call them 2)

recode pemaritl (1=1) (2 5 = 2) (3/4=3) (6=4)
*After recoding:
*1 = Married spouse present
*2 = Married spouse absent or separated
*3 = Widowed/divorced
*4 = Never married   

recode peeduca (31/38=1) (39=2) (40/42=3) (43=4) (44/46=5)
*After recoding:
*1 = less than high school
*2 = high school
*3 = some college 
*4 = college
*5 = graduate degree   

*Now gestcen does not exist and only the gestfips exist. 
#delimit ;

recode gestfips 
1=63 //AL
2=94 //AK
4=86 //AZ
5=71 //AR
6=93 //CA
8=84 //CO
9=16 //CT
10=51 //DE
11=53 //DC
12=59 //FL
13=58 //GA
15=95 //HI
16=82 //ID
17=33 //IL
18=32 //IN
19=42 //IA
20=47 //KS
21=61 //KY
22=72 //LA
23=11 //ME
24=52 //MD
25=14 //MA
26=34 //MI
27=41 //MN
28=64 //MS
29=43 //MO
30=81 //MT
31=46 //NE
32=88 //NV
33=12 //NH
34=22 //NJ
35=85 //NM
36=21 //NY
37=56 //NC
38=44 //ND
39=31 //OH
40=73 //OK
41=92 //OR
42=23 //PA
44=15 //RI
45=57 //SC
46=45 //SD
47=62 //TN
48=74 //TX
49=87 //UT
50=13 //VT
51=54 //VA
53=91 //WA
54=55 //WV
55=35 //WI
56=83 //WY
, generate(gestcen)
;

#delimit cr


sort hrhhid pulineno perace pesex peage hrmis

replace pwcmpwgt = 0 if peage < 16
*Probably pwcmpwgt is already zero for peage <16
rename  pwcmpwgt fweight
replace fweight = fweight/100


tostring hrhhid2, replace
*Before 200404, hrhhid2 is created as string but after that, hrhhid2 (which is already in the data) is float. 
*So I convert hrhhid2 into string. The other way around was tried but in very rare cases, huhhnum takes value -1 in pre-2004 data.
*This makes the destring command useless (destring is actually not carried out in the code). 

gen year = int(`x'/100)
gen month = `x'-year*100

compress
save cpsm`x'.dta, replace

local x = `x' + 1
if (`x'-13)/100 == int((`x'-13)/100) {
    local x = `x' + 88
    }
}

