# About ----
# Code to process NZ GREEN Grid grid spy data

# Libraries ----
library(data.table)
library(lubridate) # keep here otherwise data.table masks various functions
library(readr)
library(greenGridr)

# Local parameters ----
fpath <- "/Volumes/hum-csafe/Research Projects/GREEN Grid/_RAW DATA/GridSpyData/" # location of data
#fpath <- "~/Data/NZGreenGrid/gridspy/1min_orig/" # location of data
pattern <- "rf_25*at1.csv$" # e.g. *at1.csv$ filters only 1 min data

outPath <- "/Volumes/hum-csafe/Research Projects/GREEN Grid/Clean_data/gridSpy/1min/" # place to save them
#outPath <- "~/Data/NZGreenGrid/gridspy/consolidated/"

dataThreshold <- 3000 # assume any files smaller than this (bytes) = no data

# Code: ----
# > Get the full 1 minute file listing ----
# Use the path and pattern to specify
print(paste0("Looking for files matching ", pattern, " in ", fpath))
filesDT <- as.data.table(list.files(path = fpath, pattern = pattern, # use the pattern to filter e.g. 1m from 30s files
                               recursive = TRUE))

filesDT <- filesDT[, c("hhID","fileName") := tstrsplit(V1, "/")]
filesDT <- filesDT[, fullPath := paste0(fpath, hhID,"/",fileName)]

print(paste0("Found ", nrow(filesDT), " files from ", uniqueN(filesDT$hhID), " households."))

# check
head(filesDT)

# > Load, process & save the ones which probably have data ----

hhIDs <- unique(filesDT$hhID) # list of household ids
allFileInfoDT <- data.table()

for(hh in hhIDs){
  print(paste0("Loading: ", hh))
  tempHhDT <- data.table() # create data.table to hold file contents
  filesToLoad <- filesDT[hhID == hh, fullPath]
  for(f in filesToLoad){
    # check file
    # print(paste0("Checking: ", f))
    rf <- path.expand(f) # just in case of ~ etc
    finfo <- file.info(rf)
    allFileInfoDT <- rbind(allFileInfoDT, as.data.table(finfo))
    fsize <- file.size(rf)
    if(fsize > dataThreshold){ # set above
      print(paste0("Checking: ", f))
      print(paste0("File size = ", file.size(f), " so probably OK")) # files under 3kb are probably empty
      # attempt to load the file
      tempDT <- fread(f)
      tempHhDT <- rbind(tempHhDT, tempDT, fill = TRUE) # just in case there are different numbers of columns (quite likely!)
    }
  }
  # > tidy column names ----
  tempHhDT$r_dateTime <- tempHhDT$"date NZ"
  tempHhDT$"date NZ" <- NULL #to avoid confusion
  # > remove duplicates caused by over-lapping files ----
  nObs <- nrow(tempHhDT)
  print(paste0("N rows before removal of dublicates: ", nObs))
  tempHhDT <- unique(tempHhDT)
  nObs <- nrow(tempHhDT)
  print(paste0("N rows after removal of dublicates: ", nObs))
  # > set month (tests dateTime = OK) ----
  print(paste0("Setting month & year"))
  tempHhDT$month <- month(tempHhDT$r_dateTime) # requires lubridate
  tempHhDT$year <- year(tempHhDT$r_dateTime) # requires lubridate
  # > save out by year & month ----
  months <- unique(tempHhDT$month)
  years <- unique(tempHhDT$year)
  for(m in months){
    for(y in years){
      ofile <- paste0(outPath, hh,"_", y, "_", m, "_all_1min_data.csv")
      write_csv(tempHhDT[month == m & year == y], ofile)
      print(paste0("Saved ", ofile))
      cmd <- paste0("gzip -f ", "'", ofile, "'") # gzip it - use quotes in case of spaces in file name
      try(system(cmd)) # in case it fails - if it does there will just be .csv files (not gzipped) - e.g. under windows
    }
  }
}

summary(allFileInfoDT)
