---
title: 'Processing, cleaning and saving NZ GREEN Grid project 1 minute electricity
  consumption data'
author: 'Ben Anderson (b.anderson@soton.ac.uk, `@dataknut`)'
date: 'Last run at: 2018-05-02 17:08:00'
output:
  html_document:
    code_folding: hide
    fig_caption: true
    keep_md: true
    number_sections: true
    self_contained: no
    toc: true
    toc_float: true
    toc_depth: 2
  pdf_document:
    toc: true
    toc_depth: 2
    number_sections: true
---





\newpage

# Citation

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

Generally tracked via our git.soton [repo](https://git.soton.ac.uk/ba1e12/nzGREENGrid).
 
## Support

This work was supported by:

 * The [University of Otago](https://www.otago.ac.nz/)
 * The New Zealand [Ministry of Business, Innovation and Employment (MBIE)](http://www.mbie.govt.nz/)
 * [SPATIALEC](http://www.energy.soton.ac.uk/tag/spatialec/) - a [Marie Skłodowska-Curie Global Fellowship](http://ec.europa.eu/research/mariecurieactions/about-msca/actions/if/index_en.htm) based at the University of Otago’s [Centre for Sustainability](http://www.otago.ac.nz/centre-sustainability/staff/otago673896.html) (2017-2019) & the University of Southampton's Sustainable Energy Research Group (2019-202).
 
This work uis (c) 2018 the University of Southampton.

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
  
  # now loop over the files and collect metadata
  for(f in fListCompleteDT[,fullPath]){
    if(fullFb){print(paste0("Checking ", f))}
    rf <- path.expand(f) # just in case of ~ etc
    fsize <- file.size(rf)
    fmtime <- ymd_hms(file.mtime(rf), tz = "Pacific/Auckland") # requires lubridate
    fListCompleteDT <- fListCompleteDT[fullPath == f, fSize := fsize]
    fListCompleteDT <- fListCompleteDT[fullPath == f, fMTime := fmtime]
    fListCompleteDT <- fListCompleteDT[fullPath == f, fMDate := as.Date(fmtime)]
    fListCompleteDT <- fListCompleteDT[fullPath == f, dateColName := paste0("unknown - file not loaded (fsize = ", fsize, ")")]
    # only try to read files where we think there might be data
    if(fsize > dataThreshold){
      if(fullFb){print(paste0("fSize (", fsize, ") > threshold (", dataThreshold, ") -> loading ", f))}
      row1DT <- fread(f, nrows = 1)
      # what is the date column called?
      fListCompleteDT <- fListCompleteDT[fullPath == f, dateColName := "unknown - can't tell"]
      if(nrow(select(row1DT, contains("NZ"))) > 0){ # requires dplyr
        setnames(row1DT, 'date NZ', "dateTime_char")
        row1DT <- row1DT[, dateColName := "date NZ"]
        fListCompleteDT <- fListCompleteDT[fullPath == f, dateColName := "date NZ"]
      } 
      if(nrow(select(row1DT, contains("UTC"))) > 0){ # requires dplyr
        setnames(row1DT, 'date UTC', "dateTime_char")
        row1DT <- row1DT[, dateColName := "date UTC"]
        fListCompleteDT <- fListCompleteDT[fullPath == f, dateColName := "date UTC"]
      }
      # split dateTime
      row1DT <- row1DT[, c("date_char", "time_char") := tstrsplit(dateTime_char, " ")]
      # add example of date to metadata - presumably they are the same in each file?!
      fListCompleteDT <- fListCompleteDT[fullPath == f, dateExample := row1DT[1, date_char]]
      
      if(fullFb){print(paste0("Checking date formats in ", f))}
      dt <- gs_checkDates(row1DT)
      fListCompleteDT <- fListCompleteDT[fullPath == f, dateFormat := dt[1, dateFormat]]
      if(fullFb){print(paste0("Done ", f))}
    }
  }
  if(baTest | fullFb){print("All files checked")}
  # any date formats are still ambiguous need a deeper inspection using the full file - could be slow
  fAmbig <- fListCompleteDT[dateFormat == "ambiguous", fullPath]
  
  for(fa in fAmbig){
    if(baTest | fullFb){print(paste0("Checking ambiguous date formats in ", fa))}
    dt <- fread(fa)
    if(nrow(select(dt, contains("NZ"))) > 0){ # requires dplyr
      setnames(dt, 'date NZ', "dateTime_char")
      
    } 
    if(nrow(select(dt, contains("UTC"))) > 0){ # requires dplyr
      setnames(dt, 'date UTC', "dateTime_char")
      
    }
    dt <- dt[, c("date_char", "time_char") := tstrsplit(dateTime_char, " ")]
    dt <- gs_checkDates(dt)
    # set what we now know (or guess!)
    fListCompleteDT <- fListCompleteDT[fullPath == fa, dateFormat := dt[1,dateFormat]]
  }
      
  ofile <- paste0(outPath, indexFile)
  print(paste0("Saving 1 minute data files metadata to ", ofile))
  write.csv(fListCompleteDT, ofile)
  print("Done")
}
```

```
## [1] "Processing file list and getting file meta-data (please be patient)"
## [1] "All files checked"
## [1] "Checking ambiguous date formats in ~/Data/NZGreenGrid/gridspy/1min_orig/rf_25/12Oct2016-20Nov2017at1.csv"
## [1] "Checking ambiguous date formats in ~/Data/NZGreenGrid/gridspy/1min_orig/rf_46/12Oct2016-20Nov2017at1.csv"
## [1] "Saving 1 minute data files metadata to ~/Data/NZGreenGrid/gridspy/consolidated/fListCompleteDT.csv"
## [1] "Done"
```

```r
print(paste0("Overall we have ", nrow(fListCompleteDT), " files from ", uniqueN(fListCompleteDT$hhID), " households."))
```

```
## [1] "Overall we have 1915 files from 4 households."
```

```r
# for use below
nFiles <- nrow(fListCompleteDT)
nFilesNotLoaded <- nrow(fListCompleteDT[dateColName %like% "unknown"])
```

Overall we have 1,915 files from 4 households. Of the 1,915,  1,495 (78.07%) were _not_ loaded/checked as their file sizes indicated that they contained no data.

We now need to check how many of the loaded files have an ambiguous or default date - these could introduce errors.


```r
t <- fListCompleteDT[, .(nFiles = .N), keyby = .(dateColName, dateFormat)]

kable(caption = "Number of files with given date column names by inferred date format", t)
```



Table: Number of files with given date column names by inferred date format

dateColName                                dateFormat                                        nFiles
-----------------------------------------  -----------------------------------------------  -------
date NZ                                    dmy                                                    1
date NZ                                    mdy                                                    2
date NZ                                    ymd                                                    4
date NZ                                    ymd - default (check as m & d may be reversed)         2
date UTC                                   ambiguous                                              2
date UTC                                   ymd                                                  248
date UTC                                   ymd - default (check as m & d may be reversed)       161
unknown - file not loaded (fsize = 2751)   NA                                                   604
unknown - file not loaded (fsize = 43)     NA                                                   891

Results to note:

 * There are 2 ambiguous files
 * The non-loaded files only have 2 distinct file sizes, confirming that they are unlikely to contain useful data. 
 
We now inspect the ambiguous and (some of) the default files.

To help with data cleaning the following table lists files that are ambiguous.


```r
# list ambigious files
aList <- fListCompleteDT[dateFormat == "ambiguous", .(file = V1, dateColName, dateExample, dateFormat)]

kable(caption = "Files with ambigious date formats", aList)
```



Table: Files with ambigious date formats

file                               dateColName   dateExample   dateFormat 
---------------------------------  ------------  ------------  -----------
rf_25/12Oct2016-20Nov2017at1.csv   date UTC      11-10-16      ambiguous  
rf_46/12Oct2016-20Nov2017at1.csv   date UTC      11-10-16      ambiguous  

Looking at the file names we will assume they are dmy.


```r
fListCompleteDT <- fListCompleteDT[dateFormat == "ambiguous", dateFormat := "dmy - inferred"]
```


The following table lists 'date NZ' files which are set by default only - do they look OK to assume dateFormat?


```r
# list default files
aList <- fListCompleteDT[dateColName == "date NZ" & dateFormat %like% "default", .(file = V1, fSize, dateColName, dateExample, dateFormat)]

kable(caption = "Files with inferred default date formats", head(aList))
```



Table: Files with inferred default date formats

file                                 fSize  dateColName   dateExample   dateFormat                                     
--------------------------------  --------  ------------  ------------  -----------------------------------------------
rf_01/1Jan2014-24May2014at1.csv    6255737  date NZ       2014-01-06    ymd - default (check as m & d may be reversed) 
rf_02/1Jan2014-24May2014at1.csv    6131625  date NZ       2014-03-03    ymd - default (check as m & d may be reversed) 

These look OK if we compare the file names with the dateExample.

The following table lists 'date NZ' files which are set by default only - do they look OK to assume dateFormat?


```r
# list default files
aList <- fListCompleteDT[dateColName == "date UTC" & dateFormat %like% "default", .(file = V1, fSize, dateColName, dateExample, dateFormat)]

kable(caption = "Files with inferred default date formats", head(aList))
```



Table: Files with inferred default date formats

file                                 fSize  dateColName   dateExample   dateFormat                                     
---------------------------------  -------  ------------  ------------  -----------------------------------------------
rf_46/10Apr2017-11Apr2017at1.csv    292721  date UTC      2017-04-09    ymd - default (check as m & d may be reversed) 
rf_46/10Aug2017-11Aug2017at1.csv    292888  date UTC      2017-08-09    ymd - default (check as m & d may be reversed) 
rf_46/10Dec2017-11Dec2017at1.csv    292823  date UTC      2017-12-09    ymd - default (check as m & d may be reversed) 
rf_46/10Feb2017-11Feb2017at1.csv    286736  date UTC      2017-02-09    ymd - default (check as m & d may be reversed) 
rf_46/10Feb2018-11Feb2018at1.csv    299084  date UTC      2018-02-09    ymd - default (check as m & d may be reversed) 
rf_46/10Jan2017-11Jan2017at1.csv    297659  date UTC      2017-01-09    ymd - default (check as m & d may be reversed) 

These also look OK so we will stick with the following derived date formats:


```r
t <- fListCompleteDT[, .(nFiles = .N), keyby = .(dateColName, dateFormat)]

kable(caption = "Number of files with given date column names by final imputed date format", t)
```



Table: Number of files with given date column names by final imputed date format

dateColName                                dateFormat                                        nFiles
-----------------------------------------  -----------------------------------------------  -------
date NZ                                    dmy                                                    1
date NZ                                    mdy                                                    2
date NZ                                    ymd                                                    4
date NZ                                    ymd - default (check as m & d may be reversed)         2
date UTC                                   dmy - inferred                                         2
date UTC                                   ymd                                                  248
date UTC                                   ymd - default (check as m & d may be reversed)       161
unknown - file not loaded (fsize = 2751)   NA                                                   604
unknown - file not loaded (fsize = 43)     NA                                                   891

## Data file quality checks

The following chart shows the distribution of these files over time using their sizes. Note that white indicates the presence of small files which may not contain observations.


```r
myCaption <- paste0("Data source: ", fpath,
                    "\nUsing data received up to ", Sys.Date())

plotDT <- fListCompleteDT[, .(nFiles = .N,
                              meanfSize = mean(fSize)), 
                          keyby = .(hhID, date = as.Date(fMDate))]

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


The following chart shows the same chart but only for files which we think contain data.


```r
myCaption <- paste0("Data source: ", fpath,
                    "\nUsing data received up to ", Sys.Date())

plotDT <- fListCompleteDT[!is.na(dateFormat), .(nFiles = .N,
                              meanfSize = mean(fSize)), 
                          keyby = .(hhID, date = as.Date(fMDate))]

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

![](processNZGGElecCons1minData_files/figure-html/loadedFileSizesPlot-1.png)<!-- -->

```r
ggsave(paste0(outPath, "gridSpyLoadedFileListSizeTilePlot.png"))
```

```
## Saving 7 x 5 in image
```

# Load data files

In this section we load the data files that have a file size > 3000 bytes. Things to note:

 * We assume that any files smaller than this value have no observations. This is based on:
     * Manual inspection of several small files
     * The identical (small) file sizes involved
     * _But_ we should probably test the first few lines to double check...
 * We have to deal with quite a lot of duplication some of which has caused the different date formats. See our [repo issues list](https://git.soton.ac.uk/ba1e12/nzGREENGrid/issues?scope=all&utf8=%E2%9C%93&state=all).
 
The following table shows the number of files per household that we willl load.


```r
filesToLoadDT <- fListCompleteDT[!is.na(dateFormat)]

t <- filesToLoadDT[, .(nFiles = .N,
                       meanSize = mean(fSize),
                       minFileDate = min(fMDate),
                       maxFileDate = max(fMDate)), keyby = .(hhID)]

kable(caption = "Summary of household files to load", t)
```



Table: Summary of household files to load

hhID     nFiles     meanSize  minFileDate   maxFileDate 
------  -------  -----------  ------------  ------------
rf_01         3   15548174.7  2016-09-20    2016-09-30  
rf_02         3   10134268.3  2016-09-20    2016-09-30  
rf_25         3   12341581.3  2016-06-08    2017-11-21  
rf_46       411     605048.1  2016-06-08    2018-02-21  



```r
# > Load, process & save the ones which probably have data ----
fListCompleteDT <- fListCompleteDT[, fileLoaded := "No"] # set default
hhIDs <- unique(filesToLoadDT$hhID) # list of household ids
hhStatDT <- data.table() # stats collector
for(hh in hhIDs){
  tempHhDT <- data.table() # hh data collector
  print(paste0("Loading: ", hh))
  filesToLoad <- filesToLoadDT[hhID == hh, fullPath]
  for(f in filesToLoad){
    if(fullFb){print(paste0("File size (", f, ") = ", 
                            filesToLoadDT[fullPath == f, fSize], 
                            " so probably OK"))} # files under 3kb are probably empty
    # attempt to load the file
    tempDT <- fread(f)
    if(fullFb){print("File loaded")}
    # set some file stats
    fListCompleteDT <- fListCompleteDT[fullPath == f, fileLoaded := "Yes"]
    fListCompleteDT <- fListCompleteDT[fullPath == f, nObs := nrow(tempDT)] # could include duplicates
    
    # what is the date column called?
      if(nrow(select(tempDT, contains("NZ"))) > 0){ # requires dplyr
        setnames(tempDT, 'date NZ', "dateTime_char")
        tempDT <- tempDT[, dateColName := "date NZ"]
      } 
      if(nrow(select(tempDT, contains("UTC"))) > 0){ # requires dplyr
        setnames(tempDT, 'date UTC', "dateTime_char")
        tempDT <- tempDT[, dateColName := "date UTC"]
      }
      
      # Now use the pre-inferred dateFormat
      tempDT <- tempDT[, dateFormat := filesToLoadDT[fullPath == f, dateFormat]]
      tempDT <- tempDT[dateFormat %like% "mdy" & dateColName %like% "NZ", r_dateTime := mdy_hm(dateTime_char, tz = "Pacific/Auckland")] # requires lubridate
      tempDT <- tempDT[dateFormat %like% "dmy" & dateColName %like% "NZ", r_dateTime := dmy_hm(dateTime_char, tz = "Pacific/Auckland")] # requires lubridate
      tempDT <- tempDT[dateFormat %like% "ydm" & dateColName %like% "NZ", r_dateTime := ymd_hm(dateTime_char, tz = "Pacific/Auckland")] # requires lubridate
      tempDT <- tempDT[dateFormat %like% "ymd" & dateColName %like% "NZ", r_dateTime := ymd_hm(dateTime_char, tz = "Pacific/Auckland")] # requires lubridate
      tempDT <- tempDT[dateFormat %like% "mdy" & dateColName %like% "UTC", r_dateTime := mdy_hm(dateTime_char, tz = "UTC")] # requires lubridate
      tempDT <- tempDT[dateFormat %like% "dmy" & dateColName %like% "UTC", r_dateTime := dmy_hm(dateTime_char, tz = "UTC")] # requires lubridate
      tempDT <- tempDT[dateFormat %like% "ydm" & dateColName %like% "UTC", r_dateTime := ymd_hm(dateTime_char, tz = "UTC")] # requires lubridate
      tempDT <- tempDT[dateFormat %like% "ymd" & dateColName %like% "UTC", r_dateTime := ymd_hm(dateTime_char, tz = "UTC")] # requires lubridate
      if(fullFb){
        print(head(tempDT))
        print(summary(tempDT))
        #print(table(tempDT$dateFormat))
        }
    
    fListCompleteDT <- fListCompleteDT[fullPath == f, obsStartDate := min(as.Date(tempDT$r_dateTime))] # should be a sensible number and not NA
    fListCompleteDT <- fListCompleteDT[fullPath == f, obsEndDate := max(as.Date(tempDT$r_dateTime))] # should be a sensible number and not NA
    fListCompleteDT <- fListCompleteDT[fullPath == f, nCircuits := ncol(select(tempDT, contains("$")))] # check for the number of circuits - all seem to contain "$"
    tempHhDT <- rbind(tempHhDT, tempDT, fill = TRUE) # just in case there are different numbers of columns (quite likely!)
  }
  
  # > Remove duplicates caused by over-lapping files and dates etc ----
  # Need to remove all test vars for this
  try(tempHhDT$dateColName <- NULL)
  try(tempHhDT$dateFormat <- NULL)
  
  #nObs <- nrow(tempHhDT)
  #print(paste0("N rows before removal of duplicates: ", nObs))
  tempHhDT <- unique(tempHhDT)
  #nObs <- nrow(tempHhDT)
  #print(paste0("N rows after removal of duplicates: ", nObs))
  
  hhStatTempDT <- tempHhDT[, .(nObs = .N),keyby = (date = as.Date(r_dateTime))] # can't do sensible summary stats on W as some circuits are sub-sets of others!
  hhStatTempDT <- hhStatTempDT[, hhID := hh]
  
  hhStatDT <- rbind(hhStatDT,hhStatTempDT) # add to the collector
  
  # > Save hh file ----
  ofile <- paste0(outPath, "1min/", hh,"_all_1min_data.csv")
  write_csv(tempHhDT, ofile)
  print(paste0("Saved ", ofile, ", gzipping..."))

  print("Col names: ")
  print(names(tempHhDT))
  cmd <- paste0("gzip -f ", "'", path.expand(ofile), "'") # gzip it - use quotes in case of spaces in file name, expand path if needed
  try(system(cmd)) # in case it fails - if it does there will just be .csv files (not gzipped) - e.g. under windows
  print(paste0("Gzipped ", ofile))
  tempHhDT <- NULL # just in case
}
```

```
## [1] "Loading: rf_01"
## [1] "Saved ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_01_all_1min_data.csv, gzipping..."
## [1] "Col names: "
## [1] "dateTime_char"      "Kitchen power$1632" "Heating$1633"      
## [4] "Mains$1634"         "Lights$1635"        "Hot water$1636"    
## [7] "Range$1637"         "r_dateTime"        
## [1] "Gzipped ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_01_all_1min_data.csv"
## [1] "Loading: rf_02"
## [1] "Saved ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_02_all_1min_data.csv, gzipping..."
## [1] "Col names: "
## [1] "dateTime_char"               "Fridge$1572"                
## [3] "Cooking Bath tile heat$1573" "Hot Water$1574"             
## [5] "Mains$1575"                  "Heating$1576"               
## [7] "Lights$1577"                 "r_dateTime"                 
## [1] "Gzipped ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_02_all_1min_data.csv"
## [1] "Loading: rf_25"
## [1] "Saved ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_25_all_1min_data.csv, gzipping..."
## [1] "Col names: "
## [1] "dateTime_char"                  "Heat Pump$2758"                
## [3] "Hob & Kitchen Appliances$2759"  "Oven$2760"                     
## [5] "Hot Water - Controlled$2761"    "Incomer 2 - Uncontrolled $2762"
## [7] "Incomer 1 - Uncontrolled $2763" "r_dateTime"                    
## [9] "Incomer 1 - Uncontrolled$2757" 
## [1] "Gzipped ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_25_all_1min_data.csv"
## [1] "Loading: rf_46"
## [1] "Saved ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_46_all_1min_data.csv, gzipping..."
## [1] "Col names: "
##  [1] "dateTime_char"                    
##  [2] "Laundry & Bedrooms$4228"          
##  [3] "Kitchen & Bedrooms$4229"          
##  [4] "Incomer - Uncontrolled$4230"      
##  [5] "Hot Water - Controlled$4231"      
##  [6] "Heat Pumps (2x) & Power$4232"     
##  [7] "Lighting$4233"                    
##  [8] "Heat Pumps (2x) & Power$4399"     
##  [9] "Hot Water - Controlled$4400"      
## [10] "Incomer - Uncontrolled$4401"      
## [11] "Kitchen & Bedrooms$4402"          
## [12] "Laundry & Bedrooms$4403"          
## [13] "Lighting$4404"                    
## [14] "Incomer Voltage$4405"             
## [15] "r_dateTime"                       
## [16] "Laundry & Bedrooms1$4228"         
## [17] "Kitchen & Bedrooms1$4229"         
## [18] "Incomer - Uncontrolled1$4230"     
## [19] "Hot Water - Controlled1$4231"     
## [20] "Heat Pumps (2x) & Power1$4232"    
## [21] "Lighting1$4233"                   
## [22] "Heat Pumps (2x) & Power2$4399"    
## [23] "Hot Water - Controlled2$4400"     
## [24] "Incomer - Uncontrolled2$4401"     
## [25] "Kitchen & Bedrooms2$4402"         
## [26] "Laundry & Bedrooms2$4403"         
## [27] "Lighting2$4404"                   
## [28] "Heat Pumps (2x) & Power_Imag$4399"
## [29] "Hot Water - Controlled_Imag$4400" 
## [30] "Incomer - Uncontrolled_Imag$4401" 
## [31] "Kitchen & Bedrooms_Imag$4402"     
## [32] "Laundry & Bedrooms_Imag$4403"     
## [33] "Lighting_Imag$4404"               
## [1] "Gzipped ~/Data/NZGreenGrid/gridspy/consolidated/1min/rf_46_all_1min_data.csv"
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

# Data quality analysis

Now produce some data quality plots & tables.

The following plots show the number of observations per day per household. In theory we should not see:

 * dates before 2014 or in to the future (they indicate data conversion errors)
 * more than 1440 observations per day (they indicate potentially duplicate data)


```r
# tile plot ----
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

![](processNZGGElecCons1minData_files/figure-html/loadedFilesObsPlots-1.png)<!-- -->

```r
ggsave(paste0(outPath, "gridSpyLoadedFileNobsTilePlot.png"))
```

```
## Saving 7 x 5 in image
```

```r
# point plot ----
ggplot(hhStatDT, aes( x = date, y = nObs, colour = hhID)) +
  geom_point() +
  scale_x_date(date_labels = "%Y %b", date_breaks = "6 months") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5)) + 
  labs(title = "N observations per household per day for all loaded grid spy data",
       caption = paste0(myCaption,
                        "\nOnly files of size > ", dataThreshold, " bytes loaded")
       
  )
```

![](processNZGGElecCons1minData_files/figure-html/loadedFilesObsPlots-2.png)<!-- -->

```r
ggsave(paste0(outPath, "gridSpyLoadedFileNobsPointPlot.png"))
```

```
## Saving 7 x 5 in image
```

The following table shows the min/max observations per day and min/max dates for each household. As above, we should not see:

 * dates before 2014 or in to the future (indicates date conversion errors)
 * more than 1440 observations per day (indicates potentially duplicate observations)
 
 We should also not see NA in any row (indicates date conversion errors). 
 
 If we do see any of these then we still have data cleaning work to do!


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
rf_25        45     1500  2015-05-24   2016-10-22 
rf_46       305     3000  2015-03-26   2018-02-19 

# Runtime



```r
t <- proc.time() - startTime

elapsed <- t[[3]]
```

Analysis completed in 462.786 seconds ( 7.71 minutes) using [knitr](https://cran.r-project.org/package=knitr) in [RStudio](http://www.rstudio.com) with R version 3.4.4 (2018-03-15) running on x86_64-apple-darwin15.6.0.

# R environment

R packages used:

 * base R - for the basics [@baseR]
 * data.table - for fast (big) data handling [@data.table]
 * ggplot2 - for slick graphics [@ggplot2]
 * dplyr - for select and contains [@dplyr]
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
## [4] ggplot2_2.2.1       lubridate_1.7.4     data.table_1.10.4-3
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
## [28] compiler_3.4.4    pillar_1.2.2      scales_0.5.0.9000
## [31] backports_1.1.2   pkgconfig_2.0.1
```
