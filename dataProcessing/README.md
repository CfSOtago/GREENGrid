# NZ GREEN Grid Data processing code
[NZ GREEN Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) data includes:

 * 1 minute electricity power (W) data for c 40 households in NZ monitored from early 2014 using [gridSpy](https://gridspy.com/) monitors on each power circuit (and the incoming power)
 * Occupant time-use diaries (focused on energy use)
 * Dwelling & appliance surveys

_None_ of the code here will work unless you also have access to the data. While we have plans to deposit anonymised versions of the data with a suitable data archive (any offers?!), the data is currently held on the University of Otago High Performance Storage filestore and access is controlled by the [NZ GREEN Grid project administrator](mailto:jane.wilcox@otago.ac.nz?subject=Access to GREEN Grid data (via github readme)).

## 1 min electricity power data

Data has been downloaded from the [gridSpy](https://gridspy.com/) servers initially as large file dumps for each household but more recently as daily downloads from each household. 

 * input data location: /hum-csafe/Research Projects/GREEN Grid/_RAW DATA/GridSpyData/
 * output data location: /hum-csafe/ResearchProjects/GREENGrid/Clean_data/safe/gridSpy/1min/

See the [gridSpy Readme](gridSpy/) for more information.
 
## Time Use Diaries

Two time-use diaries were conducted, one for each of the two samples (Unison & PowerCo). 

 * input data location: /hum-csafe/Research Projects/GREEN Grid/ -> various
 * output data location: /hum-csafe/ResearchProjects/GREENGrid/Clean_data/safe/TUD/
 
See the [TUD Readme](tud/) for more information.
 
## Dwelling and appliance surveys

See the [surveys Readme](surveys/) for more information.

## Other data

This directory probably contains code for processing other datasets which were not collected by GREEN Grid but obtained from other sources. [#YMMV](https://en.wiktionary.org/wiki/YMMV).
