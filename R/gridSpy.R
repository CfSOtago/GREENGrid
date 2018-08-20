#' Loads cleaned grid spy power data for a given circuit between two dates into a data.table
#'
#' \code{extractCleanGridSpyCircuit} loops over all clean household grid spy data files and loads each in turn using \code{readr::read_csv}. It filters each file to
#' extract data for particular circuits between two dates and creates some derived time/date variables before
#' using \code{rbind} to create a single data.table which is saved but not returned.
#'
#' Function matches \code{circuitPattern} to extract specific circuits and selects observations between
#'  \code{dateFrom} and \code{dateTo}. Use this to extract any circuit you want between any given dates.
#'
#'  \code{circuitPattern} is passed to the \code{data.table} operator \code{\%like\%} so wild cards & stuff may work. YMMV
#'
#'  Use of \code{readr::read_csv} enables .gz files to be autoloaded and proper parsing of dateTimes.
#'
#' @param fPath location of files to load
#' @param exFile location to save the results
#' @param circuitPattern the circuit pattern to match
#' @param dateFrom date to start extract (inclusive)
#' @param dateTo date to end extract (inclusive)
#'
#' @import data.table
#' @import readr
#' @import hms
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk}
#' @export
#'
#'
extractCleanGridSpyCircuit <- function(fPath, exFile, circuitPattern, dateFrom, dateTo) {
  # check files to load
  fPattern <- "*.csv.gz"
  print(paste0("#-> Looking for data using pattern = ", fPattern, " in ", fPath, " - could take a while..."))
  #> Get the file list as a data.table ----
  # This will list all the individual household data files
  fListDT <- data.table::as.data.table(list.files(path = fPath, pattern = fPattern))

  nFiles <- nrow(fListDT)
  print(paste0("#-> Found ", tidyNum(nFiles), " files"))

  fListDT <- fListDT[, fullPath := paste0(fPath, V1)] # add in full path as it doesn't return in list.files()

  filesToLoad <- fListDT[, fullPath]

  print(paste0("#-> Looking for circuits matching: ", circuitPattern))
  print(paste0("#-> Filtering on date range: ", dateFrom, " - ", dateTo))

  # loop over household files in list and rbind them
  # rbind  into a single data.table
  nFiles <- length(filesToLoad)
  print(paste0("#-> Loading ",nFiles, " files..."))
  # don't use parallel for file reading - no performance gain
  # http://stackoverflow.com/questions/22104858/is-it-a-good-idea-to-read-write-files-in-parallel
  dataDT <- data.table::data.table()
  # file load loop ----
  for(f in filesToLoad){# should use lapply but...
    print(paste0("#--> Loading ", f))
    df <- readr::read_csv(f,
                          progress = FALSE
                          ) # decodes .gz on the fly, requires readr
    dt <- as.data.table(df)
    # check household id
    hh <- unique(dt$hhID)
    # remove cols we don't need & which break the rbind if they parsed differently due to different TZs
    dt$dateTime_orig <- NULL
    dt$TZ_orig <- NULL
    # filter on circuit label pattern and dates (inclusive)
    filteredDT <- dt[circuit %like% circuitPattern & # match circuitPattern
                       as.Date(r_dateTime) >= dateFrom & # filter by dateFrom
                       as.Date(r_dateTime) <= dateTo] # filter by dateTo
    print(paste0("#--> ", hh," : Found ", tidyNum(nrow(filteredDT)), " that match -> ", circuitPattern,
                 " <- between ", dateFrom, " and ", dateTo,
                 " out of ", tidyNum(nrow(dt))))

    if(nrow(filteredDT) > 0){# if any matches...
      print("#--> Summary of extracted rows:")
      print(summary(filteredDT))
      print(table(filteredDT$circuit))
      dataDT <- rbind(dataDT, filteredDT)
    }
  }
  print("#-> Finished extraction")
  if(nrow(dataDT) > 0){
    # we got a match

    print(paste0("#-> Found ", tidyNum(nrow(dataDT)),
                 " observations matching -> ", circuitPattern, " <- in ",
                 uniqueN(dataDT$hhID), " households between ", dateFrom, " and ", dateTo))

    print("#-> Summary of all extracted rows:")
    print(summary(dataDT))

    #> Save the data out for future re-use ----
    print(paste0("#-> Saving ", exFile))
    data.table::fwrite(dataDT, exFile)
    # compress it
    cmd <- paste0("gzip -f ", "'", path.expand(exFile), "'") # gzip it - use quotes in case of spaces in file name, expand path if needed
    try(system(cmd)) # in case it fails - if it does there will just be .csv files (not gzipped) - e.g. under windows
    print(paste0("#-> Gzipped ", exFile))
  } else {
    # no matches -> fail
    stop(paste0("#-> No matching data found, please check your search pattern (", circuitPattern,
                ") or your dates..."))
  }

  print(paste0("#-> Extracted ", tidyNum(nrow(dataDT)), " rows of data"))

  # return summary table of DT
  print(summary(dataDT))
  return(dataDT) # for testing
}

#' Loads cleaned grid spy power data for all households between two dates into a single data.table
#'
#' \code{loadCleanGridSpyData} checks to see if the extract file already exists. If not it loops over a file list and loads each in turn using \code{readr::read_csv}. It filters each file to
#' extract data between two dates and creates some derived time/date variables before
#' using \code{rbind} to create a single data.table which is saved and returned.
#'
#' Function selects observations between
#'  \code{dateFrom} and \code{dateTo}.
#'
#'  Use of \code{readr::read_csv} enables .gz files to be autoloaded and proper parsing of dateTimes.
#'
#' @param fPath location of files to load
#' @param dateFrom date to start extract (inclusive)
#' @param dateTo date to end extract (inclusive)
#'
#' @import data.table
#' @import readr
#' @import hms
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk}
#' @export
#'
#'
loadCleanGridSpyData <- function(iFile, fPath, dateFrom, dateTo) {
  # check files to load
  fPattern <- "*.csv.gz"
  print(paste0("Looking for data using pattern = ", fPattern, " in ", fPath, " - could take a while..."))
  #> Get the file list as a data.table ----
  fListDT <- data.table::as.data.table(list.files(path = fPath, pattern = fPattern))

  nFiles <- nrow(fListDT)
  print(paste0("Found ", tidyNum(nFiles), " files"))

  fListDT <- fListDT[, fullPath := paste0(fPath, V1)] # add in full path as it doesn't return in list.files()

  filesToLoad <- fListDT[, fullPath]

  print(paste0("# Looking for circuits matching: ", circuitPattern))
  print(paste0("# Filtering on date range: ", dateFrom, " - ", dateTo))

  # loop over files in list and rbind them
  # load into a single data.table
  nFiles <- length(filesToLoad)
  print(paste0("# Loading ",nFiles, " files..."))
  # don't use parallel for file reading - no performance gain
  # http://stackoverflow.com/questions/22104858/is-it-a-good-idea-to-read-write-files-in-parallel
  dataDT <- data.table::data.table()
  # file load loop ----
  for(f in filesToLoad){# should use lapply but...
    print(paste0("# Loading ", f))
    df <- readr::read_csv(f,
                          progress = FALSE,
                          col_types = list(col_character(), col_datetime(), col_character(), col_double())
    ) # decodes .gz on the fly, requires readr
    dt <- as.data.table(df)
    # filter on dates (inclusive)
    filteredDT <- dt[as.Date(r_dateTime) >= dateFrom & # filter by dateFrom
                       as.Date(r_dateTime) <= dateTo] # filter by dateTo
    print(paste0("# Found: ", tidyNum(nrow(filteredDT)),
                 " between ", dateFrom, " and ", dateTo,
                 " out of ", tidyNum(nrow(dt))))

    if(nrow(filteredDT) > 0){# if any matches...
      print("Summary of extracted rows:")
      print(summary(filteredDT))
      dataDT <- rbind(dataDT, filteredDT)
    }
  }
  print("# Finished extraction")
  if(nrow(dataDT) > 0){
    # we got a match
    # derived variables ----
    print("# > Setting useful dates & times (slow)")
    dataDT <- dataDT[, timeAsChar := format(r_dateTime, format = "%H:%M:%S")] # creates a char
    dataDT <- dataDT[, obsHourMin := hms::as.hms(timeAsChar)] # creates an hms time, makes graphs easier
    dataDT$timeAsChar <- NULL # drop to save space

    print(paste0("# Found ", tidyNum(nrow(dataDT)),
                 " observations in ", uniqueN(dataDT$hhID),
                 " households between ", dateFrom, " and ", dateTo))

    print("Summary of all extracted rows:")
    print(summary(dataDT))

    #> Save the data out for future re-use ----
    fName <- paste0(circuitPattern, "_", dateFrom, "_", dateTo, "_observations.csv")
    ofile <- paste0(outPath, "dataExtracts/", fName)
    print(paste0("Saving ", ofile))
    data.table::fwrite(dataDT, ofile)
    # do not compress so can use fread to load back in
  } else {
    # no matches -> fail
    stop(paste0("No matching data found, please check your search pattern (", circuitPattern,
                ") or your dates..."))
  }

  print(paste0("# Loaded ", tidyNum(nrow(dataDT)), " rows of data"))

  # return DT
  return(dataDT)
}

