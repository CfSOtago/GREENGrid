####- R script to extract and save all observations whose circuit labels match a given pattern between two dates -####
# If the pattern/dateFrom/dateTo file already exists, it skips and ends

# Header ----

# Housekeeping ----
rm(list=ls(all=TRUE)) # remove all objects from workspace

#> Set start time ----
startTime <- proc.time()

#> Load nzGREENGrid package ----
library(nzGREENGrid) # local utilities

#> Packages needed in this .Rmd file ----
rmdLibs <- c("data.table", # data munching
             "dplyr", # data munching
             "readr"
)
# load them
nzGREENGrid::loadLibraries(rmdLibs)

#> Local parameters ----
circuitPattern <- "Hot Water"
dateFrom <- "2015-04-01"
dateTo <- "2016-03-31"

plotCaption <- paste0("Source: ", outPath,
                      "\nCircuits: ", circuitPattern, " from ", dateFrom, " to ", dateTo)

fullFb <- 0 # switch on (1) or off (0) full feedback
baTest <- 0 # test (1) or full (0) run?
refresh <- 1 # refresh data even if it seems to already exsit

b2Kb <- 1024 #http://whatsabyte.com/P1/byteconverter.htm
b2Mb <- 1048576

# location of sample data
gsMasterFile <- path.expand("~/Syncplicity Folders/Green Grid Project Management Folder/Gridspy/Master list of Gridspy units.xlsx")

if(baTest == 1){
  # Local test
  dPath <- "~/Data/NZGreenGrid/" # BA laptop test set
  fPath <- paste0(dPath,"gridspy/1min_orig/") # location of original data
  outPath <- paste0(dPath, "safe/gridSpy/1min/") # place to save them / load from
} else {
  # full monty
  dPath <- "/Volumes/hum-csafe/Research Projects/GREEN Grid/" # HPS
  fPath <- paste0(dPath,"_RAW DATA/GridSpyData/") # location of data
  outPath <- paste0(dPath, "Clean_data/safe/gridSpy/1min/") # place to save them
}

# Code ----

if(baTest){
  msg <- paste0("#-> Test run using reduced data from ", outPath)
} else {
  msg <- paste0("#-> Full run using all data from ", outPath)
}

print(msg)

fPath <- paste0(outPath, "data/")

fName <- paste0(fName <- paste0(circuitPattern, "_", dateFrom, "_", dateTo, "_observations.csv"))

exFile <- paste0(outPath, "dataExtracts/", fName)
exFileTest <- paste0(exFile, ".gz")

if(file.exists(exFileTest) & refresh == 0){
  print(paste0(exFileTest, " exists and refresh = 0 so skipping.")) # prevents the file load in the function
  print(paste0("=> You may need to check your circuit label pattern (",
               circuitPattern ,") and date filter settings (",
               dateFrom, " - ", dateTo, ") if this is not what you expected."))
} else {
  print(paste0(exFileTest, " does not exist & refresh == 1 so running extraction.")) # prevents the file load in the function
  extractedDT <- nzGREENGrid::extractCleanGridSpyCircuit(fPath, exFile, circuitPattern, dateFrom, dateTo)
  print(paste0("Done - look for data in: ", exFileTest))
}

t <- proc.time() - startTime

elapsed <- t[[3]]

print(paste0("Analysis completed in ",
             round(elapsed,2),
             " seconds ( ",
             round(elapsed/60,2), " minutes) using [RStudio](http://www.rstudio.com) with ",
             R.version.string, " running on ", R.version$platform, "."))
