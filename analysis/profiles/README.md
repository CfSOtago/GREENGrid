# NZ GREEN Grid
Repo supporting analysis of the [NZ GREEN Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) project data. This data includes:

 * 1 minute electricity power (W) data for c 40 households in NZ monitored from early 2014
 * Dwelling & appliance surveys
 * Occupant time-use diaries (focused on energy use)

More info and the data processing code is in the [dataProcessing](dataProcessing) folder. 

_None_ of the code here will work unless you also have access to the data. While we have plans to deposit anonymised versions of the data with a suitable data archive (any offers?!), access is currently controlled by the [NZ GREEN Grid project administrator](mailto:jane.wilcox@otago.ac.nz?subject=Access to GREEN Grid data (via github readme)).

## Power demand profiles

There are two .R files in this folder:

 * nzGGProfileExtractorTemplate.Rmd - an RMarkdown template for loading the data, producing the plots and saving the extract. You should not need to edit the template;
 * nzGGProfileExtractor.R - the script that calls the template. Use the parameters in this script to set the `circuitPattern` (a string) and the two dates `dateFrom` and `dateTo` which define the timeframe to search in.
 
Depending on the parameters you set, the template will use the cleaned gridSpy data to produce seasonal mean 1 minute power demand profiles by:

 * extracting observations from each household file which match `circuitPattern` and fall between the two dates `dateFrom` and `dateTo`;
 * calculating the seasonal mean 1 minute power demand profiles;
 * saving out:
   + a report that includes plots of the profiles;
   + a large scale plot of the profiles;
   + the profiles as .csv.gz files in /hum-csafe/Research Projects/GREEN Grid/Clean_data/safe/gridSpy/1min/profiles/.
   
Note that the template uses exactly the same functions as extractGridSpy1minData.R to be found in the [dataProcessing](/ba1e12/nzGREENGrid/tree/master/dataProcessing/gridSpy) directory. If the data extraction function detects a previous extract that exactly matches (in /hum-csafe/Research Projects/GREEN Grid/Clean_data/safe/gridSpy/1min/dataExtracts/) it will use this instead to save time.

The saved .csv.gz files can then be loaded using the following code:

 * `df <- readr::read_csv("/path/to/file.csv.gz")` or 
 * `dt <- data.table::as.data.table(readr::read_csv("/path/to/file.csv.gz"))` if you prefer [data.table](https://github.com/Rdatatable/data.table/wiki)

## Running the code

Ideally the code in this folder can be used (and improved!) by others as a template for other data extractions and analyses. To do this you will need access to the cleaned data in /hum-csafe/Research Projects/GREEN Grid/Clean_data/safe/gridSpy/1min/data/ (or make your own local copy).

Then:

 * [clone](https://support.rstudio.com/hc/en-us/articles/200532077-Version-Control-with-Git-and-SVN) and install the [entire nzGREENGrid repo/package](https://git.soton.ac.uk/ba1e12/nzGREENGrid)
 * edit the following parameters in the nzGGProfileExtractor.R file:
   + `circuitPattern` (a string) and the two dates `dateFrom` and `dateTo`;
   + `localTest` - specifies cleaned data input/output location. If you are testing I suggest you save outputs locally not on to the HPS to avoid over-writing anything by mistake!
 * run nzGGProfileExtractor.R!