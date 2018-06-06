# NZ GREEN Grid Data processing code
[NZ GREEN Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) data includes:

 * 1 minute electricity power (W) data for c 40 households in NZ monitored from early 2014 using [gridSpy](https://gridspy.com/) monitors on each power circuit (and the incoming power)
 * Occupant time-use diaries (focused on energy use)
 * Dwelling & appliance surveys

_None_ of the code here will work unless you also have access to the data. While we have plans to deposit anonymised versions of the data with a suitable data archive (any offers?!), access is currently controlled by the [NZ GREEN Grid project administrator](mailto:jane.wilcox@otago.ac.nz?subject=Access to GREEN Grid data (via github readme)).

## 1 min electricity power data

Data has been downloaded from the [gridSpy](https://gridspy.com/) servers initially as large file dumps for each household but more recently as daily downloads from each household. The data is currently stored on the University of Otago's High Performance Storage filestore. There are three different R files here:

 * setup.R - sets basic parameters and is required (`source`d) by all other scripts
 * processGridSpy1minData.R - uses package functions to:
   + Load data from /hum-csafe/Research Projects/GREEN Grid/_RAW DATA/GridSpyData/
   + Check & fix errors - especially in mis-matching date formats
   + Remove duplicates
   + Concatentate data from each household into one data table per household
   + Convert from wide (bad) to [long](http://garrettgman.github.io/tidying/) (good) form - see below
   + Save out 1 file per household to a clean, long form .csv.gz file in /hum-csafe/Research Projects/GREEN Grid/Clean_data/safe/gridSpy/1min/data/
 * processGridSpy1minData.Rmd - does the same as processGridSpy1minData.R but generates an html/pdf report with data quality analysis & plots (see files listed)
 * extractGridSpy1minData.R - extracts observations from the cleaned data which match a given `circuitLabel` and lie between `dateFrom` and `dateTo` (two dates) and saves them to /hum-csafe/Research Projects/GREEN Grid/Clean_data/safe/gridSpy/1min/dataExtracts/. This has been tested on `Heat Pump`, `Hot Water` and `Lighting` - see the saved data files.

The saved clean data files have 4 columns:

 * hhID: household id
 * r_dateTime: time of observation
 * circuit: the circuit label
 * powerW: 1 minute power observation (Watts)

Each file has data for one household and there should be one file per household. As an example, these are the first 6 rows of example data for 1 household:

|hhID |	r_dateTime |	circuit |	powerW|
|------:|------:|------:|------:|
|rf_46 |	2017-04-10 00:00:00 |	Laundry & Bedrooms$4228 |	679.54|
|rf_46 |	2017-04-10 00:01:00 |	Laundry & Bedrooms$4228 |	680.02|
|rf_46 |	2017-04-10 00:02:00 |	Laundry & Bedrooms$4228 |	680.50|
|rf_46 |	2017-04-10 00:03:00 |	Laundry & Bedrooms$4228 |	680.50|
|rf_46 |	2017-04-10 00:04:00 |	Laundry & Bedrooms$4228 |	682.86|
|rf_46 |	2017-04-10 00:05:00 |	Laundry & Bedrooms$4228 |	682.39 |

See html/pdf for results of latest run but check creation date to ensure most recent.

### Running the code

 * clone or install the [entire nzGREENGrid repo/package](https://git.soton.ac.uk/ba1e12/nzGREENGrid)
 * make sure you have access to the original or a copy of the original gridSpy data folders
 * edit setup.R local parameters:
    * fullFb = 0 or 1 - setting to 1 will generate a _lot_ of feedback
    * baTest = 0 or 1 - use this to set whether you are using a test or the full dataset on the HPS
    * refreshData = 0 or 1 - use this to force as full data refresh (1) or not (0). A full refresh can take a long time...
    * also check that the data paths set are correct for input & output
 * you can now run processGridSpy1minData.R from a terminal/RStudio etc. This code could also be run on a schedule to regularly update the cleaned data.
 * you can also run processGridSpy1minData.Rmd 
 * you can also run extractGridSpy1minData.R with suitable parameters (see R code)
 
>Track outstanding [issues](https://git.soton.ac.uk/ba1e12/nzGREENGrid/issues?label_name%5B%5D=gridSpy).
 
