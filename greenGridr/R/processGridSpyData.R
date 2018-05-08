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





