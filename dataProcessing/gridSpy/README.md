# NZ GREEN Grid Data processing code
[NZ GREEN Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) data includes:

 * 1 minute electricity power (W) data for c 40 households in NZ monitored from early 2014 using [gridSpy](https://gridspy.com/) monitors on each power circuit (and the incoming power)
 * Occupant time-use diaries (focused on energy use)
 * Dwelling & appliance surveys

_None_ of the code here will work unless you also have access to the data. While we have plans to deposit anonymised versions of the data with a suitable data archive (any offers?!), access is currently controlled by the [NZ GREEN Grid project administrator](mailto:jane.wilcox@otago.ac.nz?subject=Access to GREEN Grid data (via github readme)).

## 1 min electricity power data

Data has been downloaded from the [gridSpy](https://gridspy.com/) servers initially as large file dumps for each household but more recently as daily downloads from each household. The data is currently stored on the University of Otago's High Performance Storage filestore (location: /hum-csafe/Research Projects/GREEN Grid/_RAW DATA/GridSpyData/). The code in the [gridSpy](gridSpy) folder processes all of this to:

 * Check & fix errors - especially in mis-matching date formats
 * Remove duplicates
 * Concatentate data from each household into one data table per household
 * Convert from wide (bad) to [long](http://garrettgman.github.io/tidying/) (good) form
 * Save out 1 file per household to a clean, long form .csv.gz file on the University of Otago's High Performance Storage filestore (location: /hum-csafe/Research Projects/GREEN Grid/Clean_data/safe/gridSpy/1min/data/)
 
Each saved file only has 4 columns:

 * hhID: household id
 * r_dateTime: time of observation
 * circuit: the circuit label
 * powerW: power observation (Watts)

Each file has data for one household and there should be one file per household.

As an example, here are the first few rows of one of the files:

First 6 rows of example data for 1 household:

|hhID |	r_dateTime |	circuit |	powerW|
|------:|------:|------:|------:|
|rf_46 |	2017-04-10 00:00:00 |	Laundry & Bedrooms$4228 |	679.54|
|rf_46 |	2017-04-10 00:01:00 |	Laundry & Bedrooms$4228 |	680.02|
|rf_46 |	2017-04-10 00:02:00 |	Laundry & Bedrooms$4228 |	680.50|
|rf_46 |	2017-04-10 00:03:00 |	Laundry & Bedrooms$4228 |	680.50|
|rf_46 |	2017-04-10 00:04:00 |	Laundry & Bedrooms$4228 |	682.86|
|rf_46 |	2017-04-10 00:05:00 |	Laundry & Bedrooms$4228 |	682.39 |

See html/pdf for latest run but check creation date to ensure most recent.

The .R code to do most of this can be found in the repo's [scripts](../scripts) folder. The .R script found in [gridSpy](gridSpy) runs the code. The .Rmd file found in [gridSpy](gridSpy) runs the code and produces a report on the data processing.

### Running the code

 * install the [entire nzGREENGrid repo/package](https://git.soton.ac.uk/ba1e12/nzGREENGrid)
 * make sure you have access to the original or a copy of the original gridSpy data folders
 * edit setup.R local parameters:
    * fullFb = 0 or 1 - setting to 1 will generate a _lot_ of feedback
    * baTest = 0 or 1 - use this to set whether you are using a test or the full dataset on the HPS
    * refreshData = 0 or 1 - use this to force as full data refresh (1) or not (0). A full refresh can take a long time...
    * also check that the data paths set are correct for input & output
 * you can now run processGridSpy1minData.R from a terminal/RStudio etc 
 * you can also run processGridSpy1minData.Rmd which does exactly the same thing but produces a nice html/pdf report with data quality tables and charts...
 
>Track outstanding [issues](https://git.soton.ac.uk/ba1e12/nzGREENGrid/issues?label_name%5B%5D=gridSpy).
 