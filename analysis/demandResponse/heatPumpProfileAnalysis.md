---
params:
 title: "Technical Potential of Demand Response"
 subtitle: "Heat Pump Analysis"
title: 'Technical Potential of Demand Response'
subtitle: 'Heat Pump Analysis'
author: 'Carsten Dortans (xxx@otago.ac.nz)'
date: 'Last run at: 2018-06-20 14:18:25'
output:
  bookdown::html_document2:
    toc: true
    toc_float: TRUE
    toc_depth: 2
    keep_md: TRUE
    self_contained: no
  bookdown::pdf_document2:
    toc: true
    toc_depth: 2
bibliography: '/Users/ben/git.soton/ba1e12/nzGREENGrid/bibliography.bib'
---





\newpage

# Citation

If you wish to use any of the material from this report please cite as:

 * Dortans, C. (2018) Technical Potential of Demand Response: Heat Pump Analysis, [Centre for Sustainability](http://www.otago.ac.nz/centre-sustainability/), University of Otago: Dunedin.

This work is (c) 2018 the University of Southampton.

\newpage

# About

## Circulation


Report circulation:

 * Restricted to: [NZ GREEN Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) project partners and contractors.
 
## Purpose

This report is intended to: 

 * load and test GREEN Grid heat pump and hot water profiles.

## Requirements:

 * test dataset stored at /Volumes/hum-csafe/Research Projects/GREEN Grid/Clean_data/safe/gridSpy/1min/profiles/

## History


Generally tracked via our git.soton [repo](https://git.soton.ac.uk/ba1e12/nzGREENGrid):

 * [history](https://git.soton.ac.uk/ba1e12/nzGREENGrid/commits/master)
 * [issues](https://git.soton.ac.uk/ba1e12/nzGREENGrid/issues)
 
Specific history of this code:

 * https://git.soton.ac.uk/ba1e12/nzGREENGrid/tree/master/analysis/demandResponse

## Support


This work was supported by:

 * The [University of Otago](https://www.otago.ac.nz/);
 * The [University of Southampton](https://www.southampton.ac.uk/);
 * The New Zealand [Ministry of Business, Innovation and Employment (MBIE)](http://www.mbie.govt.nz/) through the [NZ GREEN Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) project;
 * [SPATIALEC](http://www.energy.soton.ac.uk/tag/spatialec/) - a [Marie Skłodowska-Curie Global Fellowship](http://ec.europa.eu/research/mariecurieactions/about-msca/actions/if/index_en.htm) based at the University of Otago’s [Centre for Sustainability](http://www.otago.ac.nz/centre-sustainability/staff/otago673896.html) (2017-2019) & the University of Southampton's Sustainable Energy Research Group (2019-202).

We do not 'support' the code but if you have a problem check the [issues](https://git.soton.ac.uk/ba1e12/nzGREENGrid/issues) on our [repo](https://git.soton.ac.uk/ba1e12/nzGREENGrid) and if it doesn't already exist, open one. We might be able to fix it :-)
 

# Load data files

## Heat pump profiles

This file is the pre-aggregated data for all heat pump circuits in the GREEN Grid data for April 2015 - March 2016 (check!)



In this section we load and describe the  data files from /Volumes/hum-csafe/Research Projects/GREEN Grid/Clean_data/safe/gridSpy/1min/profiles/Heat Pump_2015-04-01_2016-03-31_overallSeasonalProfiles.csv.gz.


```
## Parsed with column specification:
## cols(
##   obsHourMin = col_time(format = ""),
##   season = col_character(),
##   meanW = col_double(),
##   medianW = col_double(),
##   nObs = col_integer(),
##   sdW = col_double()
## )
```


Describe using skim:


```
## Skim summary statistics
##  n obs: 5760 
##  n variables: 6 
## 
## ── Variable type:character ───────────────────────────────────────────────────────────────────────────────────────────────────
##  variable missing complete    n min max empty n_unique
##    season       0     5760 5760   6   6     0        4
## 
## ── Variable type:difftime ────────────────────────────────────────────────────────────────────────────────────────────────────
##    variable missing complete    n    min        max     median n_unique
##  obsHourMin       0     5760 5760 0 secs 86340 secs 43170 secs     1440
## 
## ── Variable type:integer ─────────────────────────────────────────────────────────────────────────────────────────────────────
##  variable missing complete    n    mean     sd   p0    p25    p50     p75
##      nObs       0     5760 5760 2474.38 193.08 2150 2402.5 2517.5 2599.25
##  p100     hist
##  2688 ▅▁▁▁▁▇▁▅
## 
## ── Variable type:numeric ─────────────────────────────────────────────────────────────────────────────────────────────────────
##  variable missing complete    n   mean     sd     p0    p25    p50    p75
##     meanW       0     5760 5760 143.52 116.99  34.99  71.88 104.76 174.71
##   medianW       0     5760 5760  17.09  67.67   0      0      0      0   
##       sdW       0     5760 5760 329.77 146.05 101.04 234.33 298.61 407.13
##    p100     hist
##  613.89 ▇▃▂▁▁▁▁▁
##  392.55 ▇▁▁▁▁▁▁▁
##  879.07 ▆▇▆▅▂▂▁▁
```


# Runtime




Analysis completed in 1.77 seconds ( 0.03 minutes) using [knitr](https://cran.r-project.org/package=knitr) in [RStudio](http://www.rstudio.com) with R version 3.5.0 (2018-04-23) running on x86_64-apple-darwin15.6.0.

# R environment

R packages used:

 * base R - for the basics [@baseR]
 * data.table - for fast (big) data handling [@data.table]
 * lubridate - date manipulation [@lubridate]
 * ggplot2 - for slick graphics [@ggplot2]
 * readr - for csv reading/writing [@readr]
 * skimr - for skim [@skimr]
 * knitr - to create this document & neat tables [@knitr]
 * nzGREENGrid - for local NZ GREEN Grid project utilities

Session info:


```
## R version 3.5.0 (2018-04-23)
## Platform: x86_64-apple-darwin15.6.0 (64-bit)
## Running under: macOS High Sierra 10.13.5
## 
## Matrix products: default
## BLAS: /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libRblas.0.dylib
## LAPACK: /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libRlapack.dylib
## 
## locale:
## [1] en_GB.UTF-8/en_GB.UTF-8/en_GB.UTF-8/C/en_GB.UTF-8/en_GB.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] bindrcpp_0.2.2    knitr_1.20        skimr_1.0.3       readr_1.1.1      
## [5] lubridate_1.7.4   ggplot2_2.2.1     dplyr_0.7.5       data.table_1.11.4
## [9] nzGREENGrid_0.1.0
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.17      pillar_1.2.3      compiler_3.5.0   
##  [4] plyr_1.8.4        bindr_0.1.1       prettyunits_1.0.2
##  [7] tools_3.5.0       progress_1.2.0    digest_0.6.15    
## [10] gtable_0.2.0      evaluate_0.10.1   tibble_1.4.2     
## [13] pkgconfig_2.0.1   rlang_0.2.1       cli_1.0.0        
## [16] rstudioapi_0.7    yaml_2.1.19       xfun_0.1         
## [19] stringr_1.3.1     hms_0.4.2         rprojroot_1.3-2  
## [22] grid_3.5.0        tidyselect_0.2.4  glue_1.2.0       
## [25] R6_2.2.2          rmarkdown_1.10    bookdown_0.7     
## [28] tidyr_0.8.1       purrr_0.2.5       reshape2_1.4.3   
## [31] magrittr_1.5      scales_0.5.0      backports_1.1.2  
## [34] htmltools_0.3.6   assertthat_0.2.0  colorspace_1.3-2 
## [37] stringi_1.2.3     lazyeval_0.2.1    munsell_0.5.0    
## [40] crayon_1.3.4
```

# References
