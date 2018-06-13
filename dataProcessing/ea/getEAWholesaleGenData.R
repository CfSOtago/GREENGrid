# Get NZ EA Wholesale Generation data ----
# Not a function
# Gets or refreshes the EA wholesale generation data from https://www.emi.ea.govt.nz/Wholesale/Datasets/Generation/Generation_MD/
# Saves them as-is and also processes to long form & saves as .csv.gz

# Load libraries ----
library(nzGREENGrid)
library(data.table)
library(readr)
library(curl)

# Parameters ----


local <- 0 # set to 1 for local file storage
refresh <- 0 # set to 1 to try to download all files even if we have them

if(local){
  lDataLoc <- path.expand("~/Data/NZGreenGrid/safe/ea/")
} else {
  lDataLoc <- path.expand("/Volumes/hum-csafe/Research Projects/GREEN Grid/_RAW DATA/EA_Generation_Data/")
}

rDataLoc <- "https://www.emi.ea.govt.nz/Wholesale/Datasets/Generation/Generation_MD/"
years <- seq(1997, 2018, 1)
months <- seq(1,12,1)

# Local functions ----

# Code ----
# Set start time ----
startTime <- proc.time()

filesToDateDT <- data.table::as.data.table(list.files(lDataLoc)) # get list of files already downloaded

for(y in years){
  for(month in months){
    # construct the filename
    if(nchar(month) == 1){
      # need to add 0 as prefix
      m <- paste0("0", month)
    } else {
      m <- month
    }
    fName <- paste0(y,m,"_Generation_MD.csv")
    print(paste0("Checking ", fName))
    test <- filesToDateDT[V1 %like% fName] # should catch .csv.gz too
    if(nrow(test) > 0 & refresh == 0){
      # Already got it & we don't want to refresh so skip
      print(paste0("Already got ", fName, " skipping"))
    } else {
      # Get it
      fullName <- paste0(rDataLoc,fName)
      print(paste0("Attempting to download ", fullName))
      # use curl function to catch errors
      req <- curl::curl_fetch_disk(fullName, "temp.csv")
      if(req$status_code != 404){
        print("File downloaded successfully, saving it")
        df <- readr::read_csv(req$content)
        readr::write_csv(df, paste0(lDataLoc, fName))
        dt <- data.table::as.data.table(df) # make dt
        genDT <- nzGREENGrid::reshapeEAGenDT(dt) # make long
        genDT <- nzGREENGrid::setEAGenTimePeriod(genDT) # set time periods to something intelligible as rTime
        genDT <- genDT[, rDate := as.Date(Trading_date)] # fix the dates so R knows what they are
        genDT <- genDT[, rDateTime := lubridate::ymd_hms(paste0(rDate, rTime))] # set full dateTime
        lfName <- paste0(y,m,"_Generation_MD_long.csv")
        print("Converted to long form, saving it")
        data.table::fwrite(genDT, paste0(lDataLoc, lfName))
        cmd <- paste0("gzip -f ", "'", path.expand(paste0(lDataLoc, lfName)), "'") # gzip it - use quotes in case of spaces in file name, expand path if needed
        try(system(cmd)) # in case it fails - if it does there will just be .csv files (not gzipped) - e.g. under windows
        print("Compressed it")
      } else {
        print(paste0("File download failed (Error = ", req$status_code, ") - does it exist at that location?"))
      }
    }
  }
}

# remove the temp file
file.remove("temp.csv")
t <- proc.time() - startTime
elapsed <- t[[3]]

print("Done")
print(paste0("Completed in ", round(elapsed/60,2), "minutes",
             "using", R.version.string, "running on ", R.version$platform))
