# Renewable Energy and the Smart Grid (GREEN Grid)

Repo supporting a wide range of analysis for the [NZ GREEN Grid project](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html).

If you're looking for the NZ GREEN Grid Household electricity demand data which was collected and archived as part of this project then you need our [data repo](https://cfsotago.github.io/GREENGridData/).

## Repo structure

This repo follows the structure of an [R package](https://github.com/ropensci/rrrpkg) and can be built & run as such. You can do this in various ways:

 * manual build & install from [github](https://github.com/CfSOtago/GREENGrid): 
     + clone the repo from https://github.com/CfSOtago/GREENGrid
     + open the project file in RStudio and use the Build -> Install and Restart menu item. Be aware that it might fail if you do not have all the required packages. If so, install them from the RStudio packages tab.
 * automatic build & install from [github](https://github.com/CfSOtago/GREENGrid):
     + `install.packages("devtools")` and then
     + `devtools::install_github("CfSOtago/GREENGrid")`

If you are using the household electricity demand data you may also need to [install our data package](https://cfsotago.github.io/GREENGridData/) using `devtools::install_github("CfSOtago/GREENGridData")`.

## Funding support

The development of the code in this repo has been supported by:

 * The [University of Otago](https://www.otago.ac.nz/)
 * The New Zealand [Ministry of Business, Innovation and Employment (MBIE)](http://www.mbie.govt.nz/)
 * The EU via [SPATIALEC](http://www.energy.soton.ac.uk/tag/spatialec/) - a [Marie Skłodowska-Curie Global Fellowship](http://ec.europa.eu/research/mariecurieactions/about-msca/actions/if/index_en.htm) based at the University of Otago’s [Centre for Sustainability](http://www.otago.ac.nz/centre-sustainability/staff/otago673896.html) (2017-2019) & the University of Southampton's Sustainable Energy Research Group (2019-202).
 
### Terms of code re-use

Read the [License](LICENSE) file.

[YMMV](http://en.wiktionary.org/wiki/YMMV)
