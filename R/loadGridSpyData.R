filterLoad <- function(f, pattern){
  df <- readr::read_csv(f,
                  progress = FALSE,
                  col_types = list(col_character(), col_datetime(), col_character(), col_double()
                                   )
  ) # decodes .gz on the fly, requires readr
  dt <- as.data.table(df)
  filteredDT <- dt[circuit %like% eval(pattern)]
  return(filteredDT)
}

#' Loads cleaned grid spy data into a data.table
#'
#' \code{getCleanGridSpyData} loops over a file list and uses `readr::read_csv` to load and `rbind` them.
#'
#' Use of read_csv enables .gz files to be autoloaded and proper parsing of dateTimes.
#'
#' @param files the files to load (so you can pass a sunset if you wish)
#' @param pattern the circuit pattern to match
#'
#' @import data.table
#' @import dplyr
#' @import readr
#' @import hms
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk}
#' @export
#'
#'
getCleanGridSpyData <- function(files) {
    # loop over files in list and rbind them
    # load into a single data.table
    nFiles <- length(files)
    print(paste0("# Loading ",nFiles, " files..."))

    # don't use parallel for file reading - no performance gain
    # http://stackoverflow.com/questions/22104858/is-it-a-good-idea-to-read-write-files-in-parallel

    df <- lapply(files, function(f)
      readr::read_csv(f,
               progress = FALSE,
               col_types = list(col_character(), col_datetime(), col_character(), col_double())
      ) # decodes .gz on the fly, requires readr https://blog.rstudio.org/2016/08/05/readr-1-0-0/
    )  %>% dplyr::bind_rows()
    # https://stackoverflow.com/questions/28657690/how-to-combine-result-of-lapply-to-a-data-frame

    dataDT <- data.table::as.data.table(df) # convert to dt
    print("# > Setting useful dates & times")
    dataDT <- dataDT[, timeAsChar := format(r_dateTime, format = "%H:%M:%S")]
    dataDT <- dataDT[, obsHourMin := hms::as.hms(timeAsChar)] # makes graphs easier
    dataDT$timeAsChar <- NULL # drop

    print("# Files loaded")
    print(paste0("# Loaded ", tidyNum(nrow(dataDT)), " rows of data"))

    # return DT
    return(dataDT)
}
