# About ----
# Code to process raw NZ GREEN Grid electricity demand data as downloaded from gridSpy
# Purpose:
# - process & (slightly) clean  raw data
# - save data to 1 .csv.gz file per household
# - report data processing/file info

# It won't work without the data so you will need access to it!

# Libraries ----
library(data.table) # for data munching
library(lubridate) # for date munching - keep here otherwise data.table masks various functions
library(readr) # for reading/writing csv
library(ggplot2) # for fancy graphs
library(greenGridr) # local utilities

# Local parameters ----

#dPath <- "/Volumes/hum-csafe/Research Projects/GREEN Grid/"
dPath <- "~/Data/NZGreenGrid/gridspy/"

#fpath <- paste0(dPath,"_RAW DATA/GridSpyData/") # location of data
fpath <- paste0(dPath,"1min_orig/") # location of data

pattern1Min <- "*at1.csv$" # e.g. *at1.csv$ filters only 1 min data

#outPath <- paste0(dPath, "Clean_data/gridSpy/") # place to save them - add "1min/" for folder etc
outPath <- paste0(dPath, "consolidated/")

indexFile <- "gridSpy1minIndex.csv"

dataThreshold <- 3000 # assume any files smaller than this (bytes) = no data or some mangled xml/html. Really, we should check the contents of each file.

# Code: ----
# > Get the file listing ----

# First check if the complete file list exists and it was created today
fListComplete <- paste0(outPath, indexFile)
if(file.exists(fListComplete)){
  print("1 minute data index file exists")
  if(as.Date(file.mtime(fListComplete)) > Sys.Date() - 2)
    print("and it was created within the last 2 days so re-using...")
    fListCompleteDT <- fread(fListComplete) 
} else {
  # create from scratch
  print("1 minute data index file does not exist and/or it was not created in the last day so re-create...")
  print(paste0("Looking for 1 minute data using pattern = ", pattern1Min, " in ", fpath))
  fListCompleteDT <- as.data.table(list.files(path = fpath, pattern = pattern1Min, # use the default pattern to filter e.g. 1m from 30s files
                                      recursive = TRUE))
  if(nrow(fListCompleteDT) == 0){
    stop(paste0("No matching data files found, please check your path (", fpath, ") or your search pattern (", pattern1Min, ")"))
  } else {
    fListCompleteDT <- fListCompleteDT[, c("hhID","fileName") := tstrsplit(V1, "/")]
    fListCompleteDT <- fListCompleteDT[, fullPath := paste0(fpath, hhID,"/",fileName)]
    print("Saving 1 minute data index file...")
    write.csv(fListCompleteDT, paste0(outPath, indexFile))
    print("Done")
  }
}

# So now we have a file list
print(paste0("Overall we have ", nrow(fListCompleteDT), " files from ", uniqueN(fListCompleteDT$hhID), " households."))

# > Load, process & save the ones which probably have data ----

hhIDs <- unique(fListCompleteDT$hhID) # list of household ids
hhStatDT <- data.table() # stats collector
for(hh in hhIDs){
  print(paste0("Loading: ", hh))
  tempHhDT <- data.table() # create data.table to hold file contents
  filesToLoad <- fListCompleteDT[hhID == hh, fullPath]
  for(f in filesToLoad){
    # check file
    # print(paste0("Checking: ", f))
    rf <- path.expand(f) # just in case of ~ etc
    fsize <- file.size(rf)
    fmtime <- ymd_hms(file.mtime(rf), tz = "Pacific/Auckland") # requires lubridate
    fListCompleteDT <- fListCompleteDT[fullPath == f, fSize := fsize]
    fListCompleteDT <- fListCompleteDT[fullPath == f, fMTime := fmtime]
    fListCompleteDT <- fListCompleteDT[fullPath == f, fMDate := as.Date(fmtime)]
    if(fsize > dataThreshold){ # set above - if OK, load file
      print(paste0("File size (", f, ") = ", file.size(f), " so probably OK")) # files under 3kb are probably empty
      # attempt to load the file
      tempDT <- fread(f)
      # set some file stats
      fListCompleteDT <- fListCompleteDT[fullPath == f, fileLoaded := "Yes"]
      fListCompleteDT <- fListCompleteDT[fullPath == f, nObs := nrow(tempDT)] # could include duplicates
      if(nrow(select(tempDT, contains("NZ"))) > 0){
        # => there is at least 1 column whose name contains NZ so we have NZ time
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
        setnames(tempDT, 'date UTC', "date_UTC")
        tempDT <- tempDT[, testDate := ifelse(substr(date_UTC,2,2) == "/" | # day is 1 digit
                                                substr(date_UTC,3,3) == "/", # 2 digits
                                              "dmy", "ymd")]
        tempDT <- tempDT[testDate == "ymd", r_dateTime := ymd_hm(date_UTC, tz = "UTC")] # requires lubridate
        tempDT <- tempDT[testDate == "dmy", r_dateTime := dmy_hm(date_UTC, tz = "UTC")]
        }
      print(head(tempDT)) # test
      fListCompleteDT <- fListCompleteDT[fullPath == f, obsStartDate := min(as.Date(tempDT$r_dateTime))]
      fListCompleteDT <- fListCompleteDT[fullPath == f, obsEndDate := max(as.Date(tempDT$r_dateTime))]
      tempHhDT <- rbind(tempHhDT, tempDT, fill = TRUE) # just in case there are different numbers of columns (quite likely!)
    } else {
      # don't load anything & skip to the next one
      fListCompleteDT <- fListCompleteDT[fullPath == f, fileLoaded := "No"]
    }
  }
  
  # > Remove duplicates caused by over-lapping files and dates etc ----
  # Need to remove all test vars for this
  try(tempDT$date_UTC <- NULL)
  try(tempDT$date_NZ <- NULL)
  try(tempDT$testDate <- NULL)
  
  nObs <- nrow(tempHhDT)
  print(paste0("N rows before removal of duplicates: ", nObs))
  tempHhDT <- unique(tempHhDT)
  nObs <- nrow(tempHhDT)
  print(paste0("N rows after removal of duplicates: ", nObs))
  
  # Add up all Wh cols
  #tempHhDT <- tempHhDT[, Sum := rowSums(.SD, na.rm = TRUE), .SDcols = grep("$", names(tempHhDT))] 
  
  hhStatTempDT <- tempHhDT[, .(nObs = .N),keyby = (date = as.Date(r_dateTime))] # can't do mean Wh as label varies
  hhStatTempDT <- hhStatTempDT[, hhID := hh]
  # 
  # ,
  # sumWh := sum(names(select(tempDT, contains("$")))
               
  hhStatDT <- rbind(hhStatDT,hhStatTempDT) # add to the collector
  
  # > Save hh file ----
  ofile <- paste0(outPath, "1min/", hh,"_all_1min_data.csv")
  write_csv(tempHhDT, ofile)
  print(paste0("Saved ", ofile, ", gzipping..."))
  cmd <- paste0("gzip -f ", "'", path.expand(ofile), "'") # gzip it - use quotes in case of spaces in file name, expand path if needed
  try(system(cmd)) # in case it fails - if it does there will just be .csv files (not gzipped) - e.g. under windows
  print(paste0("Gzipped ", ofile))
}

#> Save updated file stats for all files processed ----
print("Updating 1 minute data index file...") # write out version with file stats
#fListCompleteDT <- fListCompleteDT[, fMDate := as.Date(fMDate)] # why do we need to do this?
write.csv(fListCompleteDT, paste0(outPath, indexFile))
print("Done")

#> Generate file stats ----
fListCompleteDT[, .(meanfSize = mean(fSize),
                    nFiles = .N,
                    meanNObs = mean(nObs),
                    maxNObs = max(nObs),
                    minNObs = min(nObs)), keyby = .(fileLoaded, year(obsStartDate))]

#> Generate file stats graphs ----
print("Updating 1 minute data index graphs...")
myCaption <- paste0("Data source: ", fpath,
                    "\nUsing data received up to ", Sys.Date())

plotDT <- fListCompleteDT[, .(nFiles = .N,
                              meanfSize = mean(fSize)), 
                          keyby = .(hhID, date = as.Date(fMDate))]
#>> All files ----
myCaption <- paste0(myCaption, 
                    "\nLog file size used as some files are full year data")

ggplot(plotDT, aes( x = date, y = hhID, fill = log(meanfSize))) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "black") + 
  scale_x_date(date_labels = "%Y %b", date_breaks = "1 month") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5)) + 
  labs(title = "Mean file size of all grid spy data files received per day",
       caption = myCaption
    
  )
ggsave(paste0(outPath, "gridSpyAllFileListSizeTilePlot.png"))

plotDT <- fListCompleteDT[fileLoaded == "Yes", .(nFiles = .N,
                              meanfSize = mean(fSize)), 
                          keyby = .(hhID, date = as.Date(fMDate))]

#>> Loaded files ----
myCaption <- paste0(myCaption, 
                    "\nFiles loaded if size > 3000 bytes (assumed to have observations)")
ggplot(plotDT, aes( x = fMDate, y = hhID, fill = log(meanfSize))) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "black") +
  scale_x_date(date_labels = "%Y %b", date_breaks = "1 month") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5)) + 
  labs(title = "Mean file size of all loaded grid spy data files received per day",
       caption = paste0(myCaption,
                        "\nLog file size used as some files are full year data")
       
  )
ggsave(paste0(outPath, "gridSpyLoadedFileListSizeTilePlot.png"))

#> Save observed data stats for all files loaded ----
print("Updating 1 minute file stats...") # write out version with file stats
write.csv(hhStatDT, paste0(outPath, "hhDailyObservationsStats.csv"))
print("Done")

#>> Loaded files ----
ggplot(hhStatDT, aes( x = date, y = hhID, fill = nObs)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "black") +
  scale_x_date(date_labels = "%Y %b", date_breaks = "6 months") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5)) + 
  labs(title = "N observations per household per day for all loaded grid spy data",
       caption = myCaption
       
  )
ggsave(paste0(outPath, "gridSpyLoadedFileNobsTilePlot.png"))

ggplot(hhStatDT, aes( x = date, y = nObs, colour = hhID)) +
  geom_point() +
  scale_fill_gradient(low = "white", high = "black") +
  scale_x_date(date_labels = "%Y %b", date_breaks = "6 months") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5)) + 
  labs(title = "N observations per household per day for all loaded grid spy data",
       caption = myCaption
       
  )
ggsave(paste0(outPath, "gridSpyLoadedFileNobsPointPlot.png"))

# Stats table (so we can pick out the dateTime errors)
hhStatDT[, .(minObs = min(nObs),
             maxObs = max(nObs), # should not be more than 1440, if so suggests duplicates
             minDate = min(date),
             maxDate = max(date)),
         keyby = .(hhID)]