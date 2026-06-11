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
  1. Agriculture, Forestery, and Fisheries: 1990 Census categories between 010 and 032
  2. Mining:  1990 Census categories between 040 and 050
  3. Construction:  1990 Census categories 060
  4. 



