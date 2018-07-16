# Data processing code

## NZ GREEN Grid data

[NZ GREEN Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) data includes:

 * 1 minute electricity power (W) data for c 40 households in NZ monitored from early 2014 using [gridSpy](https://gridspy.com/) monitors on each power circuit (and the incoming power)
 * Occupant time-use diaries (focused on energy use)
 * Dwelling & appliance surveys

NB: *None* of the data is held in this repo so *none* of the code here will work unless you also have access to the data.  The original data is currently held on the University of Otago's High-Capacity Central File Storage [HCS](https://www.otago.ac.nz/its/services/hosting/otago068353.html). Access to this data is controlled by the [NZ GREEN Grid project administrator](mailto:jane.wilcox@otago.ac.nz?subject=Access to GREEN Grid raw data (via git.soton readme)).

The original data has been processed to a 'safe' form for re-use using the [nzGREENGridDatar package](https://github.com/dataknut/nzGREENGridDataR). This 'safe' version will be [made available for re-use](https://github.com/dataknut/nzGREENGridDataR) in due course but in the interim is stored on the University of Otago's High-Capacity Central File Storage [HCS](https://www.otago.ac.nz/its/services/hosting/otago068353.html) at:

 * /hum-csafe/Research Projects/GREEN Grid/Clean_data/safe/

Access to this version of the 'safe' data is also controlled by the [NZ GREEN Grid project administrator](mailto:jane.wilcox@otago.ac.nz?subject=Access to GREEN Grid 'safe' data (via git.soton readme)).

## EA

This folder contains code for processing data downloaded from the [NZ Electricity Authority](https://www.emi.ea.govt.nz/Wholesale/Datasets).

## Other data

This directory probably contains code for processing other datasets not explicitly mentioned above :-) 

Inevitably [#YMMV](https://en.wiktionary.org/wiki/YMMV).
