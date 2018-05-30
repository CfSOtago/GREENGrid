#' Loads cleaned grid spy power data for a given circuit between two dates into a data.table
#'
#' \code{getCleanGridSpyData} loops over a file list and loads each in turn using \code{readr::read_csv}. It filters each file to
#' extract data for particular circuits between two dates and creates some derived time/date variables before
#' using \code{rbind} to create a single data.table which is returned.
#'
#' Function matches \code{circuitPattern} to extract specific circuits and selects observations between
#'  \code{dateFrom} and \code{dateTo}. Use this to extract any circuit you want between any given dates.
#'
#'  \code{circuitPattern} is passed to the \code{data.table} operator \code{\%like\%} so wild cards & stuff may work. YMMV
#'
#'  Use of \code{readr::read_csv} enables .gz files to be autoloaded and proper parsing of dateTimes.
#'
#' @param files the files to load (so you can pass a subset if you wish)
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
getCleanGridSpyData <- function(files, circuitPattern, dateFrom, dateTo) {
    # loop over files in list and rbind them
    # load into a single data.table
    nFiles <- length(files)
    print(paste0("# Loading ",nFiles, " files..."))
    # don't use parallel for file reading - no performance gain
    # http://stackoverflow.com/questions/22104858/is-it-a-good-idea-to-read-write-files-in-parallel
    dataDT <- data.table::data.table()
    for(f in files){# should use lapply but...
      print(paste0("# Loading ", f))
      df <- readr::read_csv(f,
                            progress = FALSE,
                            col_types = list(col_character(), col_datetime(), col_character(), col_double()
                            )
      ) # decodes .gz on the fly, requires readr
      dt <- as.data.table(df)
      # filter on circuit label pattern and dates (inclusive)
      filteredDT <- dt[circuit %like% circuitPattern & as.Date(r_dateTime) >= dateFrom & as.Date(r_dateTime) <= dateTo]
      print(paste0("# Found: ", tidyNum(nrow(filteredDT)), " that match -> ", circuitPattern,
                   " <- between ", dateFrom, " and ", dateTo,
                   " out of ", tidyNum(nrow(dt))))
      dataDT <- rbind(dataDT, filteredDT)
      }

    print("# > Setting useful dates & times")
    dataDT <- dataDT[, timeAsChar := format(r_dateTime, format = "%H:%M:%S")]
    dataDT <- dataDT[, obsHourMin := hms::as.hms(timeAsChar)] # makes graphs easier
    dataDT$timeAsChar <- NULL # drop

    print("# Files loaded")
    print(paste0("# Loaded ", tidyNum(nrow(dataDT)), " rows of data"))

    # return DT
    return(dataDT)
}
