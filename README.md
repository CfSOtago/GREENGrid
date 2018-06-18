# NZ GREEN Grid
Repo supporting analysis of the [NZ GREEN Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) project data. This data includes:

 * 1 minute electricity power (W) data for c 40 households in NZ monitored from early 2014
 * Dwelling & appliance surveys
 * Occupant time-use diaries (focused on energy use)

More info and the data processing code is in the [dataProcessing](dataProcessing) folder. 

_None_ of the code here will work unless you also have access to the data. While we have plans to deposit anonymised versions of the data with a suitable data archive (any offers?!), access is currently controlled by the [NZ GREEN Grid project administrator](mailto:jane.wilcox@otago.ac.nz?subject=Access to GREEN Grid data (via github readme)).

## Repo structure

This repo follows the structure of an [R package](https://github.com/ropensci/rrrpkg) and can be built & run as such. You can do this in various ways:

 * manual build & install from [git.soton.ac.uk](https://git.soton.ac.uk/ba1e12/nzGREENGrid): 
     + clone the repo from https://git.soton.ac.uk/ba1e12/nzGREENGrid
     + open the project file in RStudio and use the Build -> Install and Restart menu item
 * automatic build & install from [git.soton.ac.uk](https://git.soton.ac.uk/ba1e12/nzGREENGrid): this ought to work but doesn't, possibly because `devtools` were designed for github.com (git.soton.ac.uk is a gitlab server):
     + `install.packages("devtools")` and then
     + `devtools::install_github("ba1e12/nzGREENGrid", host = "https://git.soton.ac.uk")` - NB 'host' matters, otherwise it will look on github...

## Funding support

GREEN Grid is funded by the NZ [Ministry of Business, Innovation and Employment (MBIE)](http://www.mbie.govt.nz/)

The development of the code in this repo has been supported by:

 * The [University of Otago](https://www.otago.ac.nz/)
 * The New Zealand [Ministry of Business, Innovation and Employment (MBIE)](http://www.mbie.govt.nz/)
 * The EU via [SPATIALEC](http://www.energy.soton.ac.uk/tag/spatialec/) - a [Marie Skłodowska-Curie Global Fellowship](http://ec.europa.eu/research/mariecurieactions/about-msca/actions/if/index_en.htm) based at the University of Otago’s [Centre for Sustainability](http://www.otago.ac.nz/centre-sustainability/staff/otago673896.html) (2017-2019) & the University of Southampton's Sustainable Energy Research Group (2019-202).
 
### Terms of code re-use

Read the [License](LICENSE) file.

[YMMV](http://en.wiktionary.org/wiki/YMMV)
