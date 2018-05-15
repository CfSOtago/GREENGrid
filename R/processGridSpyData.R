#' Get list of grid spy data files
#'
#' \code{getGridSpyFileList} takes a path and a pattern and searches for data files in that path which match the pattern.
#' Returns the file list as a data.frame. Use the pattern to extract 1 min files (*at1.csv$) vs 1 second files etc
#'
#' @param path the path to search
#' @param pattern the pattern to search within path
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk}
#' @export
#'
getGridSpyFileList <- function(fpath, pattern) {
  print(paste0("Looking for data using pattern = ", pattern, " in ", fpath, " - could take a while..."))
  fList <- list.files(path = fpath, pattern = pattern, # use to filter e.g. 1m from 30s files
                      recursive = TRUE)
  if(length(fList) == 0){ # if there are no files in the list...
    print(paste0("No matching data files found, please check your path (", fpath, ") or your search pattern (", pattern, ")"))
  } else {
  return(fList)
  }
}

#' Process list of 1 min grid spy data files
#'
#' \code{process1minGridSpyFileList} takes a list of 1 minute data files and processes them to extract metadata and check date formats.
#' Returns the file list as an expanded data table.
#'
#' @section Requires:
#' data.table for tstrsplit
#'
#' lubridate for munching dates
#'
#' dplyr for select/contains
#'
#' outPath: place to save interim file list
#'
#' fListInterim: name of interim file list
#'
#' @param dt the file list as a data.table
#'
#' @return Retruns dt but with new columns for the meta-data
#'
#' @importFrom data.table tstrsplit
#' @importFrom lubridate ymd_hms
#' @importFrom dplyr select contains
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk}
#' @export
#'
process1minGridSpyFileList <- function(dt){
  # dt = the file list as a data.table
  print(paste0("Processing file list and getting file meta-data (please be patient)"))
  print(data.table::is.data.table(dt))
  dt <- dt[, c("hhID","fileName") := data.table::tstrsplit(V1, "/")]
  dt <- dt[, fullPath := paste0(fpath, hhID,"/",fileName)]
  loopCount <- 1
  # now loop over the files and collect metadata
  for(f in dt[,fullPath]){
    rf <- path.expand(f) # just in case of ~ etc
    fsize <- file.size(rf)
    fmtime <- lubridate::ymd_hms(file.mtime(rf), tz = "Pacific/Auckland") # requires lubridate
    dt <- dt[fullPath == f, fSize := fsize]
    dt <- dt[fullPath == f, fMTime := fmtime]
    dt <- dt[fullPath == f, fMDate := as.Date(fmtime)]
    dt <- dt[fullPath == f, dateColName := paste0("unknown - file not loaded (fsize = ", fsize, ")")]
    # only try to read files where we think there might be data
    loadThis <- ifelse(fsize > dataThreshold, "Loading (fsize > threshold)", "Skipping (fsize < threshold)")
    if(fullFb){print(paste0("Checking file ", loopCount, " of ", nFiles ,
                            " (", round(100*(loopCount/nFiles),2), "% checked): ", loadThis))}
    if(fsize > dataThreshold){
      if(fullFb){print(paste0("fSize (", fsize, ") > threshold (", dataThreshold, ") -> loading ", f))}
      row1DT <- fread(f, nrows = 1)
      # what is the date column called?
      dt <- dt[fullPath == f, dateColName := "unknown - can't tell"]
      if(nrow(dplyr::select(row1DT, dplyr::contains("NZ"))) > 0){ # requires dplyr
        setnames(row1DT, 'date NZ', "dateTime_char")
        row1DT <- row1DT[, dateColName := "date NZ"]
        dt <- dt[fullPath == f, dateColName := "date NZ"]
      }
      if(nrow(dplyr::select(row1DT, dplyr::contains("UTC"))) > 0){ # requires dplyr
        setnames(row1DT, 'date UTC', "dateTime_char")
        row1DT <- row1DT[, dateColName := "date UTC"]
        dt <- dt[fullPath == f, dateColName := "date UTC"]
      }
      # split dateTime
      row1DT <- row1DT[, c("date_char", "time_char") := data.table::tstrsplit(dateTime_char, " ")]
      # add example of date to metadata - presumably they are the same in each file?!
      dt <- dt[fullPath == f, dateExample := row1DT[1, date_char]]

      if(fullFb){print(paste0("Checking date formats in ", f))}
      dt <- checkDates(row1DT)
      dt <- dt[fullPath == f, dateFormat := dt[1, dateFormat]]
      dt <- dt[fullPath == f, dateFormat := dt[1, dateFormat]]
      if(fullFb){print(paste0("Done ", f))}
    }
    loopCount <- loopCount + 1
  }
  print("All files checked")

  # any date formats are still ambiguous - need a deeper inspection using the full file - could be slow
  fAmbig <- dt[dateFormat == "ambiguous", fullPath]

  for(fa in fAmbig){
    if(baTest | fullFb){print(paste0("Checking ambiguous date formats in ", fa))}
    ambDT <- fread(fa)
    if(nrow(dplyr::select(ambDT, dplyr::contains("NZ"))) > 0){ # requires dplyr
      setnames(ambDT, 'date NZ', "dateTime_char")
    }
    if(nrow(dplyr::select(ambDT, dplyr::contains("UTC"))) > 0){ # requires dplyr
      setnames(ambDT, 'date UTC', "dateTime_char")
    }
    ambDT <- ambDT[, c("date_char", "time_char") := data.table::tstrsplit(dateTime_char, " ")]
    ambDT <- gs_checkDates(ambDT) # use check dates function
    # set what we now know (or guess!)
    dt <- dt[fullPath == fa, dateFormat := ambDT[1,dateFormat]]
  }
  if(nrow(fAmbig) > 0){
    print("Finished deeper checking of files with ambiguous date formats")
  }
  dt <- setnames(dt, "V1", "file")
  return(dt)
}

#' Check date formats
#'
#' \code{checkDates} takes a character column in a data.table which is thought to be a date and tries to work out what format the date is in.
#' Returns the best guess as a new column dateFormat in the data.table. If can't guess, sets dateFormat to 'ambiguous' so you can check for yourself.
#'
#' The function assumes the character column is called 'date_char' - I suppose this ought to be parameterised but...
#'
#' Requires data.table as it uses tstrsplit
#'
#' @param dt the data table to use & return
#' @importFrom  data.table tstrsplit
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk}
#' @export
#'
checkDates <- function(dt) {
  # Check the date format as it could be y-m-d or d/m/y or m/d/y :-(
  dt <- dt[, c("date_char1","date_char2", "date_char3") := data.table::tstrsplit(date_char, "/")]
  # if this split failed then tstrsplit puts the dateVar in each one so we can check
  # this assumes we never have 9-9-9 10-10-10 or 11-11-11 or 12-12-12 !
  # would be better if data.table::tstrsplit returned an error if the split failed? We could then check for NA?
  dt <- dt[, splitFailed := ifelse(date_char1 == date_char2 & date_char1 == date_char3, TRUE, FALSE)]
  # and then split on / instead
  dt <- dt[splitFailed == TRUE, c("date_char1","date_char2", "date_char3") := data.table::tstrsplit(date_char, "-")] # requires data.table

  dt$dateFormat <- "ambiguous" # default
  # Days: 1-31
  # Months: 1 - 12
  # Years: could be 2 digit 15 - 18 or 4 digit 2015 - 2018 (+)
  max1 <- max(as.integer(dt$date_char1))
  #print(paste0("max1 = " , max1))
  max2 <- max(as.integer(dt$date_char2))
  #print(paste0("max2 = " , max2))
  max3 <- max(as.integer(dt$date_char3))
  #print(paste0("max3 = " , max3))

  if(max1 > 31){
    # char 1 = year so default is ymd
    dt$dateFormat <- "ymd - default (but day/month value <= 12)"
    if(max2 > 12){
      # char 2 = day - very unlikely
      dt$dateFormat <- "ydm"
    }
    if(max3 > 12){
      # char 3 = day
      dt$dateFormat <- "ymd - definite"
    }
  }
  if(max2 > 31){
    # char 2 is year - this is very unlikely
    if(max1 > 12){
      # char 1 = day
      dt$dateFormat <- "dym"
    }
    if(max3 > 12){
      # char 3 = day
      dt$dateFormat <- "myd"
    }
  }
  if(max3 > 31){
    # char 3 is year so default is dmy
    dt$dateFormat <- "dmy - default (but day/month value <= 12)"
    if(max1 > 12){
      # char 1 = day so char 2 = month
      dt$dateFormat <- "dmy - definite"
    }
    if(max2 > 12){
      # char 2 = day so char 1 = month
      dt$dateFormat <- "mdy - definite"
    }
  }


  return(dt)
}





