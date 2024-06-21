Municipal Population Data Interpolation
Description
This project compiles and cleans municipal population data from the INEGI censuses of 2000, 2005, 2010, 2015, and 2020. The 2015 census contains 32 different files, all of which, along with the files from other years, were meticulously cleaned and merged. The final dataset includes interpolated population data for the years 2003, 2008, 2013, and 2018 at the municipal level in Mexico.

Project Details
Data Sources
INEGI censuses for the years:
2000
2005
2010
2015 (32 different files)
2020
Process
Data Compilation: Collected population data from all mentioned INEGI censuses.
Data Cleaning: Cleaned each file to ensure consistency and accuracy.
Data Merging: Merged all cleaned files into a universal database.
Data Interpolation: Interpolated census data to estimate population figures for the years 2003, 2008, 2013, and 2018 at the municipal level.
Usage
This repository contains scripts and documentation to reproduce the data cleaning and interpolation process. You can use this code to work with Mexican municipal population data or adapt it for similar datasets.

Requirements
R
dplyr
tidyr
readr
Installation
Clone the repository:
sh
Copiar código
git clone https://github.com/EtienneRicardez/Mexico-Data-Population.git
Navigate to the project directory:
sh
Copiar código
cd Mexico-Data-Population
Install required packages in R:
r
Copiar código
install.packages(c("dplyr", "tidyr", "readr"))
Usage
Run the main script to start the data processing and interpolation:

r
Copiar código
source("main.R")
License
This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgments
Special thanks to INEGI for providing the population data.
