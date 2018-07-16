# NZ GREEN Grid 'safe' data processing code
[NZ GREEN Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) data includes:

 * 1 minute electricity power (W) data for c 40 households in NZ monitored from early 2014 using [gridSpy](https://gridspy.com/) monitors on each power circuit (and the incoming power)
 * Occupant time-use diaries (focused on energy use)
 * Dwelling & appliance surveys

NB: *None* of the data is held in this repo so *none* of the code here will work unless you also have [access to the data](../../README.md).

## 1 min electricity power data

The code in this folder is intended to use the 'safe' gridSpy data created using the [nzGREENGridr package](https://github.com/dataknut/nzGREENGridr/pulls) and stored in:

 * /hum-csafe/Research Projects/GREEN Grid/Clean_data/safe/gridSpy/1min/data/

Access to this version of the 'safe' data is also controlled by the [NZ GREEN Grid project administrator](mailto:jane.wilcox@otago.ac.nz?subject=Access to GREEN Grid 'safe' data (via git.soton readme)).

The 'safe' data files have 4 columns:

 * hhID: household id
 * r_dateTime: time of observation
 * circuit: the circuit label
 * powerW: 1 minute power observation (W) - we think this is mean power over the 60 seconds

Each file has data for one household and there should be one file per household . As an example, these are the first 6 rows of example data for 1 household (rf_46):

|hhID |	r_dateTime |	circuit |	powerW|
|------:|------:|------:|------:|
|rf_46 |	2017-04-10 00:00:00 |	Laundry & Bedrooms$4228 |	679.54|
|rf_46 |	2017-04-10 00:01:00 |	Laundry & Bedrooms$4228 |	680.02|
|rf_46 |	2017-04-10 00:02:00 |	Laundry & Bedrooms$4228 |	680.50|
|rf_46 |	2017-04-10 00:03:00 |	Laundry & Bedrooms$4228 |	680.50|
|rf_46 |	2017-04-10 00:04:00 |	Laundry & Bedrooms$4228 |	682.86|
|rf_46 |	2017-04-10 00:05:00 |	Laundry & Bedrooms$4228 |	682.39|

## Available code

 * extractCleanGridSpy1minData.R - extracts observations from the cleaned data in /hum-csafe/Research Projects/GREEN Grid/Clean_data/safe/gridSpy/1min/data/ which match a given `circuitLabel` and lie between `dateFrom` and `dateTo` (two dates) and saves them to /hum-csafe/Research Projects/GREEN Grid/Clean_data/safe/gridSpy/1min/dataExtracts/. This has been tested on `Heat Pump`, `Hot Water` and `Lighting` - see the saved data files. It does not generate a fancy report.


## Running the code

 * follow the installation instructions in the [overall repo README](../README.md)
 * make sure you have access to the relevant data
 * run the code in this folder (you may need to adjust the folder paths to suit)
 
> Track outstanding [issues](https://git.soton.ac.uk/ba1e12/nzGREENGrid/issues?label_name%5B%5D=gridSpy).
 
