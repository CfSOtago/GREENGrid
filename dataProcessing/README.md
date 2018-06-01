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

See html/pdf for latest run but check creation date to ensure moast recent.

The .R code to do most of this can be found in the repo's [scripts](../scripts) folder. The .R script found here runs the code. The .Rmd file found here runs the code and produces a report on the data processing.
 
 Track outstanding [issues](https://git.soton.ac.uk/ba1e12/nzGREENGrid/issues?label_name%5B%5D=gridSpy).
 
## Time Use Diaries

Two time-use diaries were conucted, one for each of the two samples (Unison & PowerCo). The code in the [tud](tud) folder:

 * Loads and checks each diary
 * Removes any idnrtifying (potentially disclosive) variables
 * Save out 1 file per sample to /hum-csafe/ResearchProjects/GREENGrid/Clean_data/safe/TUD/
 
Each file has multiple rows per household representing different people's diaries and mulitple columns of recorded activities and locations. No further derived variables have been created (yet).

See html/pdf for latest run but check creation date to ensure moast recent.

The .R code to do most of this can be found in the .Rmd file in [tud](tud) which runs the processing and produces a report on the data processing.

Track outstanding [issues](https://git.soton.ac.uk/ba1e12/nzGREENGrid/issues?label_name%5B%5D=TUD).
 
## Dwelling and appliance surveys
