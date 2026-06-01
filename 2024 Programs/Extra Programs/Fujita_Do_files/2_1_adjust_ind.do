/* This code creates industry codes that are consistent over time. The original code is 
is by Meyer and Osborne (2005). We use fairly coase industry breakdown, which is saved in 
the varaible mjrind. 
*/
clear
set more off
cd "$dta"

local yearmth = 199401

while `yearmth'<=202212{

use cpsm`yearmth'

capture drop ind
gen ind = peioicd

scalar Cencode70=0
scalar Cencode80=0
scalar Cencode90=0
scalar Cencode00=0

capture drop mjrind
gen mjrind =.


if `yearmth'<= 198212{
	scalar Cencode70=1
	scalar Cencode80=0
	scalar Cencode90=0
	scalar Cencode00=0
}


if `yearmth'>198212&`yearmth'<= 198912{
	scalar Cencode70=0
	scalar Cencode80=1
	scalar Cencode90=0
	scalar Cencode00=0
}
	
if `yearmth'>198912&`yearmth'<=200212{
	scalar Cencode80=0
	scalar Cencode90=1
	scalar Cencode00=0
}
	
if `yearmth'>200212{
	scalar Cencode80=0
	scalar Cencode90=0
	scalar Cencode00=1
}
	

#delimit ;

***// ---- AGRICULTURE + MINING ---- //***
// Includes the Agriculture and Mining industries from Bezhad.;

// Agriculture
replace mjrind = 1 if
  (Cencode00==1 & ind >= 170 & ind <= 290) |
  (Cencode90==1 & inlist(ind, 10, 11, 31, 230, 32, 30)) |
  (Cencode80==1 & inlist(ind, 10, 11, 30, 230, 31, 20)) |
  (Cencode70==1 & inlist(ind, 17, 18, 27, 28));

// Mining
replace mjrind = 1 if 
  (Cencode00==1 & ind>=370 & ind<=490) |
  ((Cencode90==1|Cencode80==1) & inlist(ind, 42, 41, 40, 50)) |
  (Cencode70==1 & inlist(ind, 46, 48, 49, 57));
	

	
***// ---- UTILITIES ---- //***
//Includes the Utilities industry from Bezhad.;

//Utilities
replace mjrind = 2 if 
  (Cencode00==1 & ind>=570 & ind<=690) |
  (Cencode90==1 & inlist(ind, 450,451,452,470,472)) |
  (Cencode80==1 & inlist(ind, 460,461,462,470,472)) |
  (Cencode70==1 & inlist(ind, 467,469,468,477,479));
  
  
 
***// ---- CONSTRUCTION ---- //***
//Includes the Construction industry from Bezhad.;
 
//Construction
replace mjrind = 3 if
  (Cencode00==1 & ind==770) |
  ((Cencode90==1 | Cencode80==1) & ind==60) |
  (Cencode70==1 & inlist(ind, 67, 68, 69, 77));
  

***// ---- NONDURABLE MANUFACTURING ---- //***
/*Includes the Food Manufacturing, Beverage & Tobacco Product Manufacturing, 
Textile Mills, Apparel Manufacturing, Leather & Allied Products Manufacturing, 
Paper Manufacturing, Printing, Petroleum & Coal Products, Chemical, and Plastic
& Rubber Product Manufacturing industries from Bezhad.*/;

//Food Manufacturing
replace mjrind = 4 if 
  (Cencode00==1 & ind>=1070 & ind<=1290) |
  ((Cencode90==1 | Cencode80==1) & 
  inlist(ind, 110, 112, 102, 101, 100, 610, 111, 121, 122)) |
  (Cencode70==1 & 
  inlist(ind, 279, 288, 297, 278, 269, 268, 287, 298, 637));

//Beverage & Tobacco Manufacturing 
replace mjrind = 4 if
  (Cencode00==1 & (ind==1370 | ind==1390)) |
  ((Cencode90==1 | Cencode80==1) & (ind==120 | ind==130)) |
  (Cencode70==1 & inlist(ind, 289, 299));
  
//Textile Mills & Textile Products
replace mjrind = 4 if
  (Cencode00==1 & ind>=1470 & ind<=1590) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 140,141,142,150)) |
  (Cencode70==1 & inlist(ind, 308, 309, 317, 318));
  
//Apparel Manufacturing (ADJUSTED FOR 2020)
replace mjrind = 4 if
  (Cencode00==1 & ind>=1670 & ind<=1691) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 132, 151, 152)) |
  (Cencode70==1 & inlist(ind, 307, 319, 327));
  
// Leather & Allied Products Manufacturing
replace mjrind = 4 if 
  (Cencode00==1 & ind>=1770 & ind<=1790) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 221, 222, 220)) |
  (Cencode70==1 & inlist(ind,389, 397, 388));

//Paper Manufacturing
replace mjrind = 4 if 
  (Cencode00==1 & ind>=1870 & ind<=1890) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 160, 162, 161)) |
  (Cencode70==1 & inlist(ind, 328, 337, 329));
  
//Printing & Related Support Activities
replace mjrind = 4 if
  (Cencode00==1 & ind==1990) |
  ((Cencode90==1 | Cencode80==1) & ind==172) |
  (Cencode70==1 & ind==339);

//Petroleum & Coal Products Manufacturing
replace mjrind = 4 if
  (Cencode00==1 & ind>=2070 & ind<=2090) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 200, 201)) |
  (Cencode70==1 & inlist(ind, 377, 378));
  
//Chemical Manufacturing
replace mjrind = 4 if 
  (Cencode00==1 & ind>=2170 & ind<=2290) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 180, 191, 181, 190, 182, 192)) |
  (Cencode70==1 & 
  inlist(ind, 349, 357, 347, 348, 367, 358, 359, 368, 369));
 
//Plastic & Rubber Product Manufacturing
replace mjrind = 4 if 
  (Cencode00==1 & ind>=2370 & ind<=2390) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 212, 210, 211)) |
  (Cencode70==1 & inlist(ind, 379, 387));
  

***// ---- DURABLE MANUFACTURING ---- //***
/* Includes the Nonmetallic Mineral Product Manufacturing, Metal, Machinery,
Computer & Electronic Product, Electrical Equip., Appliances and Component, 
Transportation Equipment, Wood Products, and Miscellaneous Manufacturing 
industries from Bezhad. */;

//Nonmetallic Mineral Product Manufacturing
replace mjrind = 5 if
  (Cencode00==1 & ind>=2470 & ind<=2590) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 261, 252, 250, 251, 262)) |
  (Cencode70==1 & inlist(ind, 137, 128, 119, 127, 138));
  
//Metal Industries
replace mjrind = 5 if
  (Cencode00==1 & ind>=2670 & ind<=2990) |
  ((Cencode90==1 | Cencode80==1) &
  inlist(ind, 270, 271, 272, 280, 281, 282, 290, 291, 292, 300, 301)) |
  (Cencode70==1 & 
  inlist(ind, 139, 147, 148, 149, 157, 158, 159, 167, 168, 169, 258));
  
//Machinery Manufacturing (ADJUSTED FOR 2020)
replace mjrind = 5 if 
  (Cencode00==1 & ind>=3070 & ind<=3291) |
  ((Cencode90==1 | Cencode80==1) &
  inlist(ind, 311, 312, 321, 380, 320, 310, 331, 332)) |
  (Cencode70==1 & 
  inlist(ind, 178, 179, 188, 187, 177, 197, 198, 248));
  
//Computer and Electronic Product Manufacturing (3365 IS NEW IN 2020 BUT DOES NOT MATTER)
replace mjrind = 5 if 
  (Cencode00==1 & ind>=3360 & ind<=3390) |
  ((Cencode90==1 | Cencode80==1) & 
  inlist(ind, 322, 341, 371, 381, 342)) |
  (Cencode70==1 & inlist(ind, 189, 207, 208, 239, 249));
  
//Electrical Equipment, Appliances, and Compnent Manufacturing
replace mjrind = 5 if
  (Cencode00==1 & ind>=3470 & ind<=3490) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 340, 350)) |
  (Cencode70==1 & inlist(ind, 199, 209));
  
//Transportation Equipment Manufacturing
replace mjrind = 5 if
  (Cencode00==1 & ind>=3570 & ind<=3690) |
  ((Cencode90==1 | Cencode80==1) & 
  inlist(ind, 351, 352, 362, 361, 360, 370)) |
  (Cencode70==1 & 
  inlist(ind, 219, 227, 228, 229, 237, 238));
  
//Wood Product Manufacturing
replace mjrind = 5 if
  (Cencode00==1 & ind>=3770 & ind<=3895) |
  ((Cencode90==1 | Cencode80==1) &
  inlist(ind, 231, 232, 241, 242)) |
  (Cencode70==1 & 
  inlist(ind, 108, 109, 118));
  
//Miscellaneous Manufacturing
replace mjrind = 5 if
  (Cencode00==1 & ind>=3960 & ind<=3990) |
  (Cencode90==1 & inlist(ind, 372, 390, 391, 392)) |
  (Cencode80==1 & inlist(ind, 372, 390, 391, 392, 382)) |
  (Cencode70==1 & inlist(ind, 247, 259, 398, 257));
  
  
***// ---- WHOLESALE TRADE ---- //***
/*Includes the Durable Goods, Wholesalers and Nondurable Goods, Wholesalers
industries from Bezhad.*/;

//Durable Goods, Wholesalers
replace mjrind = 6 if
  (Cencode00==1 & ind>=4070 & ind<=4290) |
  (Cencode90==1 & inlist(ind, 500, 501, 502, 510, 511, 512, 521, 530, 531, 532)) |
  (Cencode80==1 & 
  inlist(ind, 500, 501, 502, 510, 511, 512, 521, 522, 530, 531, 532)) |
  (Cencode70==1 & 
  inlist(ind, 507, 557, 569, 529, 537, 538, 539, 559));

  
//Nondurable Goods, Wholesalers
replace mjrind = 6 if
  (Cencode00==1 & ind>=4370 & ind<=4590) |
  ((Cencode90==1 | Cencode80==1) &
  inlist(ind, 540, 541, 542, 550, 551, 552, 560, 561, 562, 571)) |
  (Cencode70==1 & 
  inlist(ind, 568, 508, 509, 527, 587, 528, 558, 567, 588, 679));
  

***// ---- RETAIL TRADE ---- //***
//Includes the Retail Trade industry from Bezhad.;

//Retail Trade
replace mjrind = 7 if 
  (Cencode00==1 & ind>=4670 & ind<=5790) |
  (Cencode90==1 & 
  inlist(ind,612,622,620,631,632,633,580,581,582,601,611,602,650,642,682,621,623,630,660,651,662,640,652,591,600,592,681,661,590,663,670,672,671,691)) |
  (Cencode80==1 &
  inlist(ind,612,622,620,632,640,580,581,582,601,611,602,650,642,682,621,630,631,660,651,640,652,591,600,592,681,661,590,662,670,672,671,691)) |
  (Cencode70==1 & 
  inlist(ind,607,608,609,617,618,619,627,629,638,639,647,648,649,657,658,667,668,677,678,687,688,689,698,697));


***// ---- TRANSPORTATION AND WAREHOUSING ---- //***
//Includes the Transportation and Warehousing industry from Bezhad.;

//Transportation and Warehousing
replace mjrind = 8 if 
  (Cencode00==1 & ind>=6070 & ind<=6390) |
  ((Cencode90==1 | Cencode80==1) &
  inlist(ind,421,400,420,410,401,402,422,412,411)) |
  (Cencode70==1 & inlist(ind,407,408,409,417,418,419,427,428,907));
  
  
***// ---- INFORMATION ---- //***
/*Includes the Publishing, Broadcasting & Communications, and Information 
Services & Data Processing Services Industries from Bezhad.*/;

//Publishing Industries
replace mjrind = 9 if
  (Cencode00==1 & ind>=6470 & ind<=6590) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 171, 800)) |
  (Cencode70==1 & inlist(ind, 338, 807));
  
//Broadcasting & Communications
replace mjrind = 9 if
  (Cencode00==1 & ind>=6670 & ind<=6695) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind,440,441,442)) |
  (Cencode70==1 & inlist(ind, 447, 448, 449));

//Information Services & Data Processing Services
replace mjrind = 9 if
  (Cencode00==1 & ind>=6770 & ind<=6780) |
  ((Cencode90==1 | Cencode80==1) & ind==852) |
  (Cencode70==1 & inlist(ind, 589));
  
  
***// ---- FINANCIAL SERVICES ---- //***
/*Includes the Finance & Insurance and Real Estate, Rental, & Leasing industries
from Bezhad. */;

//Finance & Insurance (ADJUSTED FOR 2020)
replace mjrind = 10 if
  (Cencode00==1 & ind>=6870 & ind<=6992) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 700,701,702,710,711)) |
  (Cencode70==1 & inlist(ind, 707, 708, 709, 717));
  
//Real Estate, Rental, & Leasing (7071-7072 ARE NEW IN 2020 BUT DOES NOT MATTER )
replace mjrind = 10 if
  (Cencode00==1 & ind>=7070 & ind<=7190) |
  (Cencode90==1 & inlist(ind, 712, 742, 801)) |
  (Cencode80==1 & ind==712) |
  (Cencode70==1 & inlist(ind, 718));
  

***// ---- PROFESSIONAL SERVICES ---- //***
/*Includes the Professional, Scientific, & Technical Services and Management, 
Admin. & Support, & Waste Management Services from Bezhad. */;

//Professional, Scientific, & Technical Services
replace mjrind = 11 if
  (Cencode00==1 & ind>=7270 & ind<=7490) |
  (Cencode90==1 & inlist(ind, 841, 890, 882, 732, 892, 891, 721, 012, 893)) |
  (Cencode80==1 & inlist(ind, 841, 890, 882, 732, 891, 721, 892, 730, 740)) |
  (Cencode70==1 & inlist(ind, 729, 738, 739, 849, 888, 889, 897));
  
//Management, Admin. & Support, & Waste Management Services
replace mjrind = 11 if
  (Cencode00==1 & ind>=7570 & ind<=7790) |
  (Cencode90==1 & inlist(ind,731,741,432,740,722,20,471)) |
  (Cencode80==1 & inlist(ind,731,742,432,741,722,21,471)) |
  (Cencode70==1 & inlist(ind,19,429,478,728,737,747,748));
  
  
***// ---- EDUCATION ---- //***
//Includes the Educational Services industry from Bezhad.;

//Educational Services
replace mjrind = 12 if
  (Cencode00==1 & ind>=7860 & ind<=7890) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind,842,850,851,860)) |
  (Cencode70==1 & inlist(ind,857,858,867,868));

  
***// ---- HEALTH SERVICES ---- //**
//Includes the Health Care and Social Assistance industries from Bezhad.;

//Health Care
replace mjrind = 13 if(Cencode00==1 & ind>=7970 & ind<=8290) |
  ((Cencode90==1 | Cencode80==1) & 
  inlist(ind, 812, 820, 821, 822, 830, 840, 831, 832, 870)) |
  (Cencode70==1 & inlist(ind,828, 829, 837, 838, 839, 847, 848, 879));
  
//Social Assistance
replace mjrind = 13 if
  (Cencode00==1 & ind>=8370 & ind<=8470) |
  (Cencode90==1 & inlist(ind, 871, 861, 862, 863)) |
  (Cencode80==1 & inlist(ind, 871, 861, 862)) |
  (Cencode70==1 & inlist(ind, 878));
  
  
***// ---- LEISURE & HOSPITALITY ---- //***
/*Includes the Arts, Entertainment, & Recreation and Accomodations & Food 
Services industries from Bezhad.*/;

//Arts, Entertainment, & Recreation
replace mjrind = 14 if
  (Cencode00==1 & ind>=8560 & ind<=8590) |
  (Cencode90==1 & inlist(ind, 810, 872, 802)) |
  (Cencode80==1 & inlist(ind, 802, 872, 801)) |
  (Cencode70==1 & inlist(ind, 808, 809, 869));
  
//Accomodations & Food Services
replace mjrind = 14 if
  (Cencode00==1 & ind>=8660 & ind<=8690) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 762, 770, 641)) |
  (Cencode70==1 & inlist(ind, 669, 777, 778));
  
  
***// ---- OTHER SERVICES ---- //***
/*Includes the Repair & Maintenance, Personal & Laundry Services, Religious,
Grantmaking, Civic, Business, & Similar Organizations and Private Households
industries from Bezhad.*/;

//Repair & Maintenance (ADJUSTED FOR 2020)
replace mjrind = 15 if
  (Cencode00==1 & ind>=8770 & ind<=8891) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 751, 750, 752, 760, 790, 782)) |
  (Cencode70==1 & inlist(ind, 749, 757, 758, 759, 789, 797));
  
//Personal & Laundry Services
replace mjrind = 15 if
  (Cencode00==1 & ind>=8970 & ind<=9090) |
  ((Cencode90==1 | Cencode80==1) & inlist(ind, 780, 772, 771, 781, 791)) |
  (Cencode70==1 & inlist(ind, 779, 787, 788, 798));
  
//Religious, Grantmaking, Civic, Business, & Similar Organizations
replace mjrind = 15 if
  (Cencode00==1 & ind>=9160 & ind<=9190) |
  (Cencode90==1 & inlist(ind, 880, 881, 873)) |
  (Cencode80==1 & inlist(ind, 880, 881)) |
  (Cencode70==1 & inlist(ind, 877, 887));
  
//Private Households
replace mjrind = 15 if
  (Cencode00==1 & ind==9290) | 
  ((Cencode90==1 | Cencode80==1) & ind==761) |
  (Cencode70==1 & inlist(ind, 769));

  

***// ---- PUBLIC ADMINISTRATION ---- //***
//Includes the Public Administration industry from Bezhad.;

//Public Administration
replace mjrind = 16 if
  (Cencode00==1 & ind>=9370 & ind<=9590) |
  ((Cencode90==1 | Cencode80==1) & 
  inlist(ind, 900,921,901,910,922,930,931,932)) |
  (Cencode70==1 & inlist(ind,917,927,937));
  
  
***// ---- MILITARY ---- //****
//Includes the Military, Etc. industry from Bezhad.;

//Military, Etc.
replace mjrind = 17 if 
  (Cencode00==1 & ind==9890) |
  ((Cencode90==1 | Cencode80==1) & ind==991);



********************************************************************************
							//Labeling Industries//
********************************************************************************
;
capture label drop mjrind;
label define mjrind 1 "Agriculture & Mining";
label define mjrind 2 "Utilities", add;
label define mjrind 3 "Construction", add;
label define mjrind 4 "Nondurable Manufacturing", add;
label define mjrind 5 "Durable Manufacturing", add;
label define mjrind 6 "Wholesale Trade", add;
label define mjrind 7 "Retail Trade", add;
label define mjrind 8 "Transportation & Warehousing", add;
label define mjrind 9 "Information", add;
label define mjrind 10 "Financial Services", add;
label define mjrind 11 "Professional Services", add;
label define mjrind 12 "Education", add;
label define mjrind 13 "Health Services", add;
label define mjrind 14 "Leisure & Hospitality", add;
label define mjrind 15 "Other Services", add;
label define mjrind 16 "Government", add;
label define mjrind 17 "Military", add;

#delimit cr

save, replace

local ++yearmth
	if (`yearmth'-13)/100 == int((`yearmth'-13)/100){
		local yearmth = `yearmth' + 88
	}
}

						

  









  
  
  










  
  
  
