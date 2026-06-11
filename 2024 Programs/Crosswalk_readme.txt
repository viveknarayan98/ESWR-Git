Readme for ind1990_LCxwalk_VN.do
Author: Joaquin Garcia-Cabo
Date: 6/11/2026

This code takes the excel file with Census data located in Data/Raw/xwalks called ind_90-00.xls and maps the Census 3 digit codes into 20  BEA industry classifications.

- Input: ind_90-00.xls: Contains 1990 Census Industry Classifiication system and its redistribution into the 2000 industry classification system. Stata only reads columns A and B.
    - Column A is the 1990 Census Code (numerical)
    - Column B is the string Category associated with the numerical value in A
    - Columns C-D: 2000 Census numerical disaggregation and category
    - Columns E-H: 1990-2000 labor force distribution across industries, and conversion factors.

- Mapping between 1990 Census and 20 BEA categories: Acemoglu crosswalk and 1990 industry codes in IPUMS: https://usa.ipums.org/usa/volii/ind1990.shtml
Ipums has 18 categories:
  1. Agriculture, Forestery, and Fisheries: 1990 Census categories between 010 and 032
  2. Mining:  1990 Census categories between 040 and 050
  3. Construction:  1990 Census categories 060
  4. Manufacturing - Nondurable goods:  1990 Census categories between 100 and 222
  5. Manufacturing - Durable goods:  1990 Census categories between 230 and 392
  6. Transportation: 1990 Census categories between 400 and 432
  7. Communications: 1990 Census categories between 440 and 442
  8. Utilities and sanitary services: 1990 Census categories between 450 and 472
  9. Wholesale trade: 1990 Census categories between 500 and 571
  10. Retail trade: 1990 Census categories between 580 and 691
  11. Finance, insurance, and Real State: 1990 Census categories between 700 and 712
  12. Business and repair services: 1990 Census categories between 721 and 760
  13. Personal services: 1990 Census categories between 761 and 791
  14. Entertaiment and recreation services: 1990 Census categories between 800 and 810
  15. Professional and related services: 1990 Census categories between 812 and 893
  16. Public Administration: 1990 Census categories between 900 and 932
  17. Armed foreces: 1990 Census categories between 940 and 960
  18. Experienced unemployed but not classified: 992

From this 18, the resulting 20 in the Stata code are composed as follows:
1. Agriculture, Forestery, and Fisheries: 1990 Census categories between 010 and 032 (unchanged)
2. Mining:  1990 Census categories between 040 and 050 (unchanged)
3. Construction:  1990 Census categories 060 (unchanged)
4. Manufacturing - Nondurable goods:  1990 Census categories between 100 and 222 (unchanged)
5. Manufacturing - Durable goods:  1990 Census categories between 230 and 392 (unchanged)
6. Transportation and warehousing: 1990 Census categories between 400 and 432 (unchanged)
7. Information: Communications (440-442) + Printing, publishing, and allied industries, except newspapers (172) + Computer and data processing services (732) + Theaters and motion pictures (800) + Video tape rental (801)
8. Utilities and sanitary services: 1990 Census categories between 450 and 472 (unchanged)
9. Wholesale trade: 1990 Census categories between 500 and 571 (unchanged)
10. Retail trade: 1990 Census categories between 580 and 691 (unchanged)
11. Finance and insurance: 1990 Census categories between 700 and 711
12. Real Estate and Rental and Leasing: 1990 Census categories 712
13. Professional, Scientific, and Technical Services: Advertising (721) + Legal services (841) + Engineering, architectural, and surveying services (882) + Research, development, and testing services (891) + Management and public relations services (892) +	Miscellaneous professional and related services (893) + Computer and data processing services (732)
14. Management of Companies and Enterprises:    1990 Census categories 892
15. Administrative and support and waste management and remediation services: Services to dwellings and other buildings (722) + Personnel supply services (731) + 	Accounting, auditing, and bookkeeping services (890)
16. Educational services:  1990 Census categories 842 - 860
17. Health care and social assistance:  1990 Census categories 812 - 840 + 861-871 + 880-881
18. Arts, entertainment, and recreation services: Bowling centers (802) + Miscellaneous entertainment and recreation services (810) + 	Museums, art galleries, and zoos (872)
19. Accommodation and food services: 1990 Census categories 762-770 + Eating and drinking places (641)
20. Other services : 740-760 + Private households (761) + 771-791 (personal services) 

Note: 732 is in to categories so the facto in the last one (13), 873 - Labor Unions is thrown away, 892 is also duplicated between 13. and 14.

After that, merged with Line_Code_description and n numerical values, and saved throwing away categories without industry (government).

