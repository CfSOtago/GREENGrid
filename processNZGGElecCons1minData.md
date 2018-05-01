---
title: "Processing, cleaning and saving NZ GREEN Grid project 1 minute electricity consumption data"
author: "Ben Anderson (b.anderson@soton.ac.uk, `@dataknut`)"
date: 'Last run at: 2018-05-01 17:09:57'
output:
  html_document:
    fig_caption: yes
    keep_md: yes
    number_sections: yes
    self_contained: no
    toc: yes
    toc_float: yes
    code_folding: "hide"
---





\newpage

> Citation

If you wish to use any of the material from this report please cite as:

 * Anderson, B. (2018) Processing, cleaning and saving NZ GREEN Grid project 1 minute electricity consumption data, University of Otago: Dunedin, NZ.

\newpage

# Introduction

Report circulation:

 * Restricted to: [NZ GREEn Grid](https://www.otago.ac.nz/centre-sustainability/research/energy/otago050285.html) project partners and contractors.

## Purpose

This report is intended to: 

 * load and clean the project electricity consumption data (Grid Spy)
 * save the cleaned data out as a single file per household
 * produce summary data quality statistics

## Requirements:

 * grid spy 1 minute data downloads

## History

Generally tracked via [git.soton](https://git.soton.ac.uk/ba1e12/nzGREENGrid).
 
## Support

This work was supported by:

 * The [University of Otago](https://www.otago.ac.nz/)
 * The New Zealand [Ministry of Business, Innovation and Employment (MBIE)](http://www.mbie.govt.nz/)
 * [SPATIALEC](http://www.energy.soton.ac.uk/tag/spatialec/) - a [Marie Skłodowska-Curie Global Fellowship](http://ec.europa.eu/research/mariecurieactions/about-msca/actions/if/index_en.htm) based at the University of Otago’s [Centre for Sustainability](http://www.otago.ac.nz/centre-sustainability/staff/otago673896.html) (2017-2019) & the University of Southampton's Sustainable Energy Research Group (2019-202).
 
 > (c) 2018 the University of Southampton.

# Obtain listing of files

In this section we generate a listing of all 1 minute data files that we have received. If we are running over the complete dataset then we will be using data from:

 * /hum-csafe/Research Projects/GREEN Grid/_RAW DATA/GridSpyData/
 
In this run we are using data from:

 * ~/Data/NZGreenGrid/gridspy/1min_orig/

If these do not match then this may be a test run.


```r
print(paste0("Looking for 1 minute data using pattern = ", pattern1Min, " in ", fpath))
```

```
## [1] "Looking for 1 minute data using pattern = *at1.csv$ in ~/Data/NZGreenGrid/gridspy/1min_orig/"
```

```r
fListCompleteDT <- as.data.table(list.files(path = fpath, pattern = pattern1Min, # use the default pattern to filter e.g. 1m from 30s files
                                            recursive = TRUE))
if(nrow(fListCompleteDT) == 0){
  stop(paste0("No matching data files found, please check your path (", fpath, ") or your search pattern (", pattern1Min, ")"))
} else {
  print(paste0("Processing file list and getting file meta-data (please be patient)"))
  fListCompleteDT <- fListCompleteDT[, c("hhID","fileName") := tstrsplit(V1, "/")]
  fListCompleteDT <- fListCompleteDT[, fullPath := paste0(fpath, hhID,"/",fileName)]
  
  for(f in fListCompleteDT[,fullPath]){
    rf <- path.expand(f) # just in case of ~ etc
    fsize <- file.size(rf)
    fmtime <- ymd_hms(file.mtime(rf), tz = "Pacific/Auckland") # requires lubridate
    fListCompleteDT <- fListCompleteDT[fullPath == f, fSize := fsize]
    fListCompleteDT <- fListCompleteDT[fullPath == f, fMTime := fmtime]
    fListCompleteDT <- fListCompleteDT[fullPath == f, fMDate := as.Date(fmtime)]
  }
  ofile <- paste0(outPath, indexFile)
  print(paste0("Saving 1 minute data files metadata to ", ofile))
  write.csv(fListCompleteDT, ofile)
  print("Done")
}
```

```
## [1] "Processing file list and getting file meta-data (please be patient)"
## [1] "Saving 1 minute data files metadata to ~/Data/NZGreenGrid/gridspy/consolidated/fListCompleteDT.csv"
## [1] "Done"
```

Overall we have 1913 files from 4 households. The following chart shows the distirbution of these files over time.


```r
myCaption <- paste0("Data source: ", fpath,
                    "\nUsing data received up to ", Sys.Date())

plotDT <- fListCompleteDT[, .(nFiles = .N,
                              meanfSize = mean(fSize)), 
                          keyby = .(hhID, date = as.Date(fMDate))]

#>> All files plots ----
ggplot(plotDT, aes( x = date, y = hhID, fill = log(meanfSize))) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "black") + 
  scale_x_date(date_labels = "%Y %b", date_breaks = "1 month") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5)) + 
  labs(title = "Mean file size of all grid spy data files received per day",
       caption = paste0(myCaption, 
                        "\nLog file size used as some files are full year data")
    
  )
```

![](processNZGGElecCons1minData_files/figure-html/allFileSizesPlot-1.png)<!-- -->

```r
ggsave(paste0(outPath, "gridSpyAllFileListSizeTilePlot.png"))
```

```
## Saving 7 x 5 in image
```

# Load data files

In this section we load the data files that have a file size > 3000 bytes. Things to note:

 * We assume that any files smaller than this value have no observations. We should probably test the first few lines to double check...
 * We have to deal with at least 2 different date formats and quite a lot of duplication
 


```r
# > Load, process & save the ones which probably have data ----

hhIDs <- unique(fListCompleteDT$hhID) # list of household ids
hhStatDT <- data.table() # stats collector
for(hh in hhIDs){
  print(paste0("Loading: ", hh))
  tempHhDT <- data.table() # create data.table to hold file contents
  fListCompleteDT <- fListCompleteDT[, fileLoaded := "No"]
  filesToLoad <- fListCompleteDT[hhID == hh & fSize > dataThreshold, fullPath] # select the files that meet our size threshold
  for(f in filesToLoad){
    print(paste0("File size (", f, ") = ", fListCompleteDT[fullPath == f, fSize], " so probably OK")) # files under 3kb are probably empty
    # attempt to load the file
    tempDT <- fread(f)
    print("File loaded")
    # set some file stats
    fListCompleteDT <- fListCompleteDT[fullPath == f, fileLoaded := "Yes"]
    fListCompleteDT <- fListCompleteDT[fullPath == f, nObs := nrow(tempDT)] # could include duplicates
    if(nrow(select(tempDT, contains("NZ"))) > 0){ # requires dplyr
      # => there is at least 1 column whose name contains NZ so we have NZ time
      #print("NZ time")
      setnames(tempDT, 'date NZ', "date_NZ")
      # Check the date format as it could be y-m-d or d/m/y :-(
      tempDT <- tempDT[, testDate := ifelse(substr(date_NZ,2,2) == "/" | # day is 1 digit
                                              substr(date_NZ,3,3) == "/" , # day is 2 digits
                                            "dmy", "ymd")] # if there is a "/" then it is d/m/y
      # Now use that to correctly parse dates
      tempDT <- tempDT[testDate == "ymd", r_dateTime := ymd_hm(date_NZ, tz = "Pacific/Auckland")] # requires lubridate
      tempDT <- tempDT[testDate == "dmy", r_dateTime := dmy_hm(date_NZ, tz = "Pacific/Auckland")]
    } else {
      # we have UTC
      #print("UTC")
      setnames(tempDT, 'date UTC', "date_UTC")
      tempDT <- tempDT[, testDate := ifelse(substr(date_UTC,2,2) == "/" | # day is 1 digit
                                              substr(date_UTC,3,3) == "/", # 2 digits
                                            "dmy", "ymd")]
      tempDT <- tempDT[testDate == "ymd", r_dateTime := ymd_hm(date_UTC, tz = "UTC")] # requires lubridate
      tempDT <- tempDT[testDate == "dmy", r_dateTime := dmy_hm(date_UTC, tz = "UTC")]
    }
    #print(head(tempDT)) # test
    fListCompleteDT <- fListCompleteDT[fullPath == f, obsStartDate := min(as.Date(tempDT$r_dateTime))]
    fListCompleteDT <- fListCompleteDT[fullPath == f, obsEndDate := max(as.Date(tempDT$r_dateTime))]
    tempHhDT <- rbind(tempHhDT, tempDT, fill = TRUE) # just in case there are different numbers of columns (quite likely!)
  }
  
  # > Remove duplicates caused by over-lapping files and dates etc ----
  # Need to remove all test vars for this
  try(tempHhDT$date_UTC <- NULL)
  try(tempHhDT$date_NZ <- NULL)
  try(tempHhDT$testDate <- NULL)
  
  #nObs <- nrow(tempHhDT)
  #print(paste0("N rows before removal of duplicates: ", nObs))
  tempHhDT <- unique(tempHhDT)
  #nObs <- nrow(tempHhDT)
  #print(paste0("N rows after removal of duplicates: ", nObs))
  
  # Add up all Wh cols
  #tempHhDT <- tempHhDT[, Sum := rowSums(.SD, na.rm = TRUE), .SDcols = grep("$", names(tempHhDT))] 
  
  hhStatTempDT <- tempHhDT[, .(nObs = .N),keyby = (date = as.Date(r_dateTime))] # can't do mean Wh as label varies
  hhStatTempDT <- hhStatTempDT[, hhID := hh]
  
  hhStatDT <- rbind(hhStatDT,hhStatTempDT) # add to the collector
  
  # > Save hh file ----
  ofile <- paste0(outPath, "1min/", hh,"_all_1min_data.csv")
  write_csv(tempHhDT, ofile)
  print(paste0("Saved ", ofile, ", gzipping..."))
  cmd <- paste0("gzip -f ", "'", path.expand(ofile), "'") # gzip it - use quotes in case of spaces in file name, expand path if needed
  try(system(cmd)) # in case it fails - if it does there will just be .csv files (not gzipped) - e.g. under windows
  print(paste0("Gzipped ", ofile))
}
```

```
## [1] "Loading: rf_01"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_01/1Jan2014-24May2014at1.csv) = 6255737 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_01/24May2014-24May2015at1.csv) = 28791553 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_01/25May2015-25May2016at1.csv) = 11597234 so probably OK"
## [1] "File loaded"
```

```
## Warning in `[<-.data.table`(x, j = name, value = value): Adding new column
## 'date_UTC' then assigning NULL (deleting it).
```

```
## [1] "Saved ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_01_all_1min_data.csv, gzipping..."
## [1] "Gzipped ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_01_all_1min_data.csv"
## [1] "Loading: rf_02"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_02/1Jan2014-24May2014at1.csv) = 6131625 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_02/24May2014-24May2015at1.csv) = 23987713 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_02/25May2015-25May2016at1.csv) = 283467 so probably OK"
## [1] "File loaded"
```

```
## Warning in `[<-.data.table`(x, j = name, value = value): Adding new column
## 'date_UTC' then assigning NULL (deleting it).
```

```
## [1] "Saved ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_02_all_1min_data.csv, gzipping..."
## [1] "Gzipped ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_02_all_1min_data.csv"
## [1] "Loading: rf_06"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/10Apr2018-11Apr2018at1.csv) = 156944 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/10Dec2017-11Dec2017at1.csv) = 156601 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/10Feb2018-11Feb2018at1.csv) = 153353 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/10Jan2018-11Jan2018at1.csv) = 153982 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/10Mar2018-11Mar2018at1.csv) = 156471 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/10Nov2017-11Nov2017at1.csv) = 155639 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/11Apr2018-12Apr2018at1.csv) = 157181 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/11Dec2017-12Dec2017at1.csv) = 157814 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/11Feb2018-12Feb2018at1.csv) = 153859 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/11Jan2018-12Jan2018at1.csv) = 153786 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/11Mar2018-12Mar2018at1.csv) = 154349 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/11Nov2017-12Nov2017at1.csv) = 155620 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/12Apr2018-13Apr2018at1.csv) = 156204 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/12Dec2017-13Dec2017at1.csv) = 157116 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/12Feb2018-13Feb2018at1.csv) = 154422 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/12Jan2018-13Jan2018at1.csv) = 153566 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/12Mar2018-13Mar2018at1.csv) = 154513 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/12Nov2017-13Nov2017at1.csv) = 155784 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/12Oct2016-20Nov2017at1.csv) = 24221496 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/13Apr2018-14Apr2018at1.csv) = 155496 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/13Dec2017-14Dec2017at1.csv) = 155225 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/13Feb2018-14Feb2018at1.csv) = 154351 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/13Jan2018-14Jan2018at1.csv) = 152591 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/13Mar2018-14Mar2018at1.csv) = 155461 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/13Nov2017-14Nov2017at1.csv) = 155701 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/14Apr2018-15Apr2018at1.csv) = 156156 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/14Dec2017-15Dec2017at1.csv) = 155056 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/14Feb2018-15Feb2018at1.csv) = 155160 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/14Jan2018-15Jan2018at1.csv) = 152395 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/14Mar2018-15Mar2018at1.csv) = 154898 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/14Nov2017-15Nov2017at1.csv) = 154948 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/15Apr2018-16Apr2018at1.csv) = 155915 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/15Dec2017-16Dec2017at1.csv) = 154847 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/15Feb2018-16Feb2018at1.csv) = 155107 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/15Jan2018-16Jan2018at1.csv) = 152637 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/15Jul2014-25May2016at1.csv) = 36333616 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/15Mar2018-16Mar2018at1.csv) = 154929 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/15Nov2017-16Nov2017at1.csv) = 155366 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/16Apr2018-17Apr2018at1.csv) = 155976 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/16Dec2017-17Dec2017at1.csv) = 154077 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/16Feb2018-17Feb2018at1.csv) = 154146 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/16Jan2018-17Jan2018at1.csv) = 152366 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/16Mar2018-17Mar2018at1.csv) = 155168 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/16Nov2017-17Nov2017at1.csv) = 154987 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/17Apr2018-18Apr2018at1.csv) = 157151 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/17Dec2017-18Dec2017at1.csv) = 154605 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/17Feb2018-18Feb2018at1.csv) = 153476 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/17Jan2018-18Jan2018at1.csv) = 153983 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/17Mar2018-18Mar2018at1.csv) = 155425 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/17Nov2017-18Nov2017at1.csv) = 156377 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/18Apr2018-19Apr2018at1.csv) = 156682 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/18Dec2017-19Dec2017at1.csv) = 155278 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/18Feb2018-19Feb2018at1.csv) = 153841 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/18Jan2018-19Jan2018at1.csv) = 156007 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/18Mar2018-19Mar2018at1.csv) = 155682 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/18Nov2017-19Nov2017at1.csv) = 157535 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/19Apr2018-20Apr2018at1.csv) = 155596 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/19Dec2017-20Dec2017at1.csv) = 155040 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/19Feb2018-20Feb2018at1.csv) = 154104 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/19Jan2018-20Jan2018at1.csv) = 155390 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/19Mar2018-20Mar2018at1.csv) = 154893 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/19Nov2017-20Nov2017at1.csv) = 155701 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/1Apr2018-2Apr2018at1.csv) = 156595 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/1Dec2017-2Dec2017at1.csv) = 154810 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/1Feb2018-2Feb2018at1.csv) = 154426 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/1Jan2018-2Jan2018at1.csv) = 154620 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/1Mar2018-2Mar2018at1.csv) = 154686 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/20Apr2018-21Apr2018at1.csv) = 155079 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/20Dec2017-21Dec2017at1.csv) = 155269 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/20Feb2018-21Feb2018at1.csv) = 154584 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/20Jan2018-21Jan2018at1.csv) = 154271 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/20Mar2018-21Mar2018at1.csv) = 155169 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/20Nov2017-21Nov2017at1.csv) = 155030 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/21Apr2018-22Apr2018at1.csv) = 154703 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/21Dec2017-22Dec2017at1.csv) = 154669 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/21Feb2018-22Feb2018at1.csv) = 155119 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/21Jan2018-22Jan2018at1.csv) = 153747 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/21Mar2018-22Mar2018at1.csv) = 156162 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/21Nov2017-22Nov2017at1.csv) = 155120 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/22Apr2018-23Apr2018at1.csv) = 155217 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/22Dec2017-23Dec2017at1.csv) = 154231 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/22Feb2018-23Feb2018at1.csv) = 154611 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/22Jan2018-23Jan2018at1.csv) = 153121 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/22Mar2018-23Mar2018at1.csv) = 155749 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/22Nov2017-23Nov2017at1.csv) = 155211 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/23Apr2018-24Apr2018at1.csv) = 156400 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/23Dec2017-24Dec2017at1.csv) = 154246 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/23Feb2018-24Feb2018at1.csv) = 154647 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/23Jan2018-24Jan2018at1.csv) = 153433 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/23Mar2018-24Mar2018at1.csv) = 155067 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/23Nov2017-24Nov2017at1.csv) = 155419 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/24Apr2018-25Apr2018at1.csv) = 157124 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/24Dec2017-25Dec2017at1.csv) = 153457 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/24Feb2018-25Feb2018at1.csv) = 154728 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/24Jan2018-25Jan2018at1.csv) = 153781 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/24Mar2018-25Mar2018at1.csv) = 155229 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/24May2014-24May2015at1.csv) = 19398444 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/24Nov2017-25Nov2017at1.csv) = 155694 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/25Apr2018-26Apr2018at1.csv) = 156496 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/25Dec2017-26Dec2017at1.csv) = 154229 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/25Feb2018-26Feb2018at1.csv) = 154273 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/25Jan2018-26Jan2018at1.csv) = 153719 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/25Mar2018-26Mar2018at1.csv) = 156019 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/25May2015-25May2016at1.csv) = 28112770 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/25Nov2017-26Nov2017at1.csv) = 156026 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/26Apr2018-27Apr2018at1.csv) = 156557 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/26Dec2017-27Dec2017at1.csv) = 155966 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/26Feb2018-27Feb2018at1.csv) = 155160 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/26Jan2018-27Jan2018at1.csv) = 153423 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/26Mar2018-27Mar2018at1.csv) = 155149 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/26May2016-11Oct2016at1.csv) = 10824473 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/26Nov2017-27Nov2017at1.csv) = 155423 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/27Apr2018-28Apr2018at1.csv) = 157287 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/27Dec2017-28Dec2017at1.csv) = 156446 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/27Feb2018-28Feb2018at1.csv) = 156539 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/27Jan2018-28Jan2018at1.csv) = 153340 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/27Mar2018-28Mar2018at1.csv) = 154187 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/27Nov2017-28Nov2017at1.csv) = 154682 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/28Apr2018-29Apr2018at1.csv) = 156873 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/28Dec2017-29Dec2017at1.csv) = 155342 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/28Feb2018-1Mar2018at1.csv) = 155918 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/28Jan2018-29Jan2018at1.csv) = 154055 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/28Mar2018-29Mar2018at1.csv) = 155418 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/28Nov2017-29Nov2017at1.csv) = 154383 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/29Dec2017-30Dec2017at1.csv) = 153845 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/29Jan2018-30Jan2018at1.csv) = 154443 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/29Mar2018-30Mar2018at1.csv) = 155003 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/29Nov2017-30Nov2017at1.csv) = 154359 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/2Apr2018-3Apr2018at1.csv) = 155092 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/2Dec2017-3Dec2017at1.csv) = 154752 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/2Feb2018-3Feb2018at1.csv) = 155019 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/2Jan2018-3Jan2018at1.csv) = 154661 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/2Mar2018-3Mar2018at1.csv) = 154010 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/30Dec2017-31Dec2017at1.csv) = 153947 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/30Jan2018-31Jan2018at1.csv) = 153829 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/30Mar2018-31Mar2018at1.csv) = 154067 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/30Nov2017-1Dec2017at1.csv) = 154805 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/31Dec2017-1Jan2018at1.csv) = 154906 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/31Jan2018-1Feb2018at1.csv) = 153717 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/31Mar2018-1Apr2018at1.csv) = 156134 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/3Apr2018-4Apr2018at1.csv) = 154995 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/3Dec2017-4Dec2017at1.csv) = 155234 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/3Feb2018-4Feb2018at1.csv) = 154791 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/3Jan2018-4Jan2018at1.csv) = 155888 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/3Mar2018-4Mar2018at1.csv) = 153765 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/4Apr2018-5Apr2018at1.csv) = 154972 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/4Dec2017-5Dec2017at1.csv) = 155171 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/4Feb2018-5Feb2018at1.csv) = 154631 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/4Jan2018-5Jan2018at1.csv) = 156633 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/4Mar2018-5Mar2018at1.csv) = 154410 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/5Apr2018-6Apr2018at1.csv) = 155277 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/5Dec2017-6Dec2017at1.csv) = 154991 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/5Feb2018-6Feb2018at1.csv) = 155700 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/5Jan2018-6Jan2018at1.csv) = 154876 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/5Mar2018-6Mar2018at1.csv) = 154627 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/6Apr2018-7Apr2018at1.csv) = 155880 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/6Dec2017-7Dec2017at1.csv) = 154146 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/6Feb2018-7Feb2018at1.csv) = 155052 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/6Jan2018-7Jan2018at1.csv) = 153082 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/6Mar2018-7Mar2018at1.csv) = 155312 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/7Apr2018-8Apr2018at1.csv) = 155196 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/7Dec2017-8Dec2017at1.csv) = 153823 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/7Feb2018-8Feb2018at1.csv) = 153986 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/7Jan2018-8Jan2018at1.csv) = 154393 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/7Mar2018-8Mar2018at1.csv) = 156059 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/8Apr2018-9Apr2018at1.csv) = 155215 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/8Dec2017-9Dec2017at1.csv) = 154740 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/8Feb2018-9Feb2018at1.csv) = 154210 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/8Jan2018-9Jan2018at1.csv) = 154371 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/8Mar2018-9Mar2018at1.csv) = 155052 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/8Nov2017-9Nov2017at1.csv) = 156449 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/9Apr2018-10Apr2018at1.csv) = 156396 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/9Dec2017-10Dec2017at1.csv) = 155670 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/9Feb2018-10Feb2018at1.csv) = 154155 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/9Jan2018-10Jan2018at1.csv) = 153872 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/9Mar2018-10Mar2018at1.csv) = 155857 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_06/9Nov2017-10Nov2017at1.csv) = 155754 so probably OK"
## [1] "File loaded"
## [1] "Saved ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_06_all_1min_data.csv, gzipping..."
## [1] "Gzipped ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_06_all_1min_data.csv"
## [1] "Loading: rf_27"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_27/15Jul2014-25May2016at1.csv) = 20059135 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_27/24May2014-24May2015at1.csv) = 22666661 so probably OK"
## [1] "File loaded"
## [1] "File size (~/Data/NZGreenGrid/gridspy/1min_orig/rf_27/25May2015-25May2016at1.csv) = 25097300 so probably OK"
## [1] "File loaded"
## [1] "Saved ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_27_all_1min_data.csv, gzipping..."
## [1] "Gzipped ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_27_all_1min_data.csv"
```

```r
#> Save observed data stats for all files loaded ----
ofile <- paste0(outPath, "hhDailyObservationsStats.csv")
print(paste0("Saving daily observations stats by hhid to ", ofile)) # write out version with file stats
```

```
## [1] "Saving daily observations stats by hhid to ~/Data/NZGreenGrid/gridspy/consolidated/hhDailyObservationsStats.csv"
```

```r
write.csv(hhStatDT, ofile)
print("Done")
```

```
## [1] "Done"
```

Now produce some data quality plots & tables.

The following plots show the number of observations per day per household. In theory we should not see:

 * dates before 2014 or in to the future (they indicate data conversion errors)
 * more than 1440 observations per day (they indicate potentially duplicate data)


```r
#>> Loaded files ----
ggplot(hhStatDT, aes( x = date, y = hhID, fill = nObs)) +
  geom_tile() +
  scale_fill_gradient(low = "red", high = "green") +
  scale_x_date(date_labels = "%Y %b", date_breaks = "6 months") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5)) + 
  labs(title = "N observations per household per day for all loaded grid spy data",
       caption = paste0(myCaption,
                        "\nOnly files of size > ", dataThreshold, " bytes loaded")
       
  )
```

![](processNZGGElecCons1minData_files/figure-html/loadedFilesObsPlot-1.png)<!-- -->

```r
ggsave(paste0(outPath, "gridSpyLoadedFileNobsTilePlot.png"))
```

```
## Saving 7 x 5 in image
```

```r
ggplot(hhStatDT, aes( x = date, y = nObs, colour = hhID)) +
  geom_point() +
  scale_x_date(date_labels = "%Y %b", date_breaks = "6 months") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5)) + 
  labs(title = "N observations per household per day for all loaded grid spy data",
       caption = paste0(myCaption,
                        "\nOnly files of size > ", dataThreshold, " bytes loaded")
       
  )
```

![](processNZGGElecCons1minData_files/figure-html/loadedFilesObsPlot-2.png)<!-- -->

```r
ggsave(paste0(outPath, "gridSpyLoadedFileNobsPointPlot.png"))
```

```
## Saving 7 x 5 in image
```

The following table shows the min/max observations per day and min/max dates. As above, we should not see:

 * dates before 2014 or in to the future (they indicate date conversion errors)
 * more than 1440 observations per day (they indicate potentially duplicate data)
 
 We should also not see NA in any row (indicates date conversion errors)


```r
# Stats table (so we can pick out the dateTime errors)
t <- hhStatDT[, .(minObs = min(nObs),
             maxObs = max(nObs), # should not be more than 1440, if so suggests duplicates
             minDate = min(date),
             maxDate = max(date)),
         keyby = .(hhID)]

kable(caption = "Summary observation stats by hhID", t)
```



Table: Summary observation stats by hhID

hhID     minObs   maxObs  minDate      maxDate    
------  -------  -------  -----------  -----------
rf_01       171     1500  2014-01-05   2015-10-20 
rf_02       215     1440  2014-03-02   2015-05-28 
rf_06       243     1500  2014-06-08   2018-04-29 
rf_27       567     1560  2014-07-27   2016-05-13 

# Runtime



```r
t <- proc.time() - startTime

elapsed <- t[[3]]
```

Analysis completed in 173.684 seconds ( 2.89 minutes) using [knitr](https://cran.r-project.org/package=knitr) in [RStudio](http://www.rstudio.com) with R version 3.4.4 (2018-03-15) running on x86_64-apple-darwin15.6.0.

# R environment

R packages used:

 * base R - for the basics [@baseR]
 * data.table - for fast (big) data handling [@data.table]
 * ggplot2 - for slick graphics [@ggplot2]
 * dplyr - for rename [@dplyr]
 * lubridate - date manipulation [@lubridate]
 * knitr - to create this document [@knitr]
 * greenGridr - for local NZ GREEN Grid utilities
 

```r
sessionInfo()
```

```
## R version 3.4.4 (2018-03-15)
## Platform: x86_64-apple-darwin15.6.0 (64-bit)
## Running under: macOS High Sierra 10.13.4
## 
## Matrix products: default
## BLAS: /Library/Frameworks/R.framework/Versions/3.4/Resources/lib/libRblas.0.dylib
## LAPACK: /Library/Frameworks/R.framework/Versions/3.4/Resources/lib/libRlapack.dylib
## 
## locale:
## [1] en_GB.UTF-8/en_GB.UTF-8/en_GB.UTF-8/C/en_GB.UTF-8/en_GB.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] knitr_1.20          dplyr_0.7.4         readr_1.1.1        
## [4] ggplot2_2.2.1       lubridate_1.7.3     data.table_1.10.4-3
## [7] greenGridr_0.1.0   
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.16      bindr_0.1.1       magrittr_1.5     
##  [4] hms_0.4.2         munsell_0.4.3     colorspace_1.3-2 
##  [7] R6_2.2.2          rlang_0.2.0.9001  highr_0.6        
## [10] stringr_1.3.0     plyr_1.8.4        tools_3.4.4      
## [13] grid_3.4.4        gtable_0.2.0      htmltools_0.3.6  
## [16] assertthat_0.2.0  yaml_2.1.18       lazyeval_0.2.1   
## [19] rprojroot_1.3-2   digest_0.6.15     tibble_1.4.2     
## [22] bindrcpp_0.2.2    glue_1.2.0        evaluate_0.10.1  
## [25] rmarkdown_1.9     labeling_0.3      stringi_1.1.7    
## [28] compiler_3.4.4    pillar_1.2.1      scales_0.5.0.9000
## [31] backports_1.1.2   pkgconfig_2.0.1
```
