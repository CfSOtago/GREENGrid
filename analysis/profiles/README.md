# NZ GREEN Grid
Repo supporting analysis of the [NZ GREEN Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) project data. This data includes:

 * 1 minute electricity power (W) data for c 40 households in NZ monitored from early 2014
 * Dwelling & appliance surveys
 * Occupant time-use diaries (focused on energy use)

More info and the data processing code is in the [dataProcessing](dataProcessing) folder. 

_None_ of the code here will work unless you also have access to the data. While we have plans to deposit anonymised versions of the data with a suitable data archive (any offers?!), access is currently controlled by the [NZ GREEN Grid project administrator](mailto:jane.wilcox@otago.ac.nz?subject=Access to GREEN Grid data (via github readme)).

## Power demand profiles

The .Rmd files in this folder all have the same form, format and general output. They use the cleaned gridSpy data to produce seasonal mean 1 minute power demand profiles per household for a number of circuit types. They do this by:

 * extracting observations from each household file which match `circitPattern` (a string) and lie between `dateFrom` abnd `dateTo` (two dates);
 * calculating the seasonal mean 1 minute power demand profiles for each household
 * saving out:
   + a report that includes plots of the profiles
   + a large scale plot of the profiles
   + the profiles as a .csv.gz file in the repo [data]() folder
 
