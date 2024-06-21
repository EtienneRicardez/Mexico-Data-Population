# Municipal Population Data Interpolation

## Description

This project compiles and cleans municipal population data from the INEGI censuses of 2000, 2005, 2010, 2015, and 2020. The 2015 census contains 32 different files, all of which, along with the files from other years, were meticulously cleaned and merged. The final dataset includes interpolated population data for the years 2003, 2008, 2013, and 2018 at the municipal level in Mexico.

## Project Details

### Data Sources

- INEGI censuses for the years:
  - 2000
  - 2005
  - 2010
  - 2015 (32 different files)
  - 2020

### Process

1. **Data Compilation:** Collected population data from all mentioned INEGI censuses.
2. **Data Cleaning:** Cleaned each file to ensure consistency and accuracy.
3. **Data Merging:** Merged all cleaned files into a universal database.
4. **Data Interpolation:** Interpolated census data to estimate population figures for the years 2003, 2008, 2013, and 2018 at the municipal level.

## Usage

This repository contains scripts and documentation to reproduce the data cleaning and interpolation process. You can use this code to work with Mexican municipal population data or adapt it for similar datasets.

## Requirements

- R
- dplyr
- tidyr
- readr

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/EtienneRicardez/Mexico-Data-Population.git
2. Navigate to the project directory:
   ```sh
   cd Mexico-Data-Population
3.- Install required packages in R:
   ```sh
   install.packages(c("dplyr", "tidyr", "readr", "readxl", "writexl", "tibble", "stringr"))
   ```

## Usage
## Installation

Run the main script to start the data processing and interpolation:
  ```sh
  source("main.R")
  ```

## Acknowledgments

Special thanks to INEGI for providing the population data and answering my calls.

