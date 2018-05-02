#' Check date fomrats
#'
#' \code{checkDates} takes character column in a data.table which is thought to be a date and tries to work out what format the date is in.
#' Returns the best guess as a new column dateFormat in the data.table. If can't guess, sets dateFormat to 'ambiguous'.
#' Assumes the character column is called 'date_char' - I suppose this ought to be parameterised but...
#' Requires data.table as it uses tstrsplit
#'
#' @param dt the data table to use & return
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk}
#' @export
#'
checkDates <- function(dt) {
  # Check the date format as it could be y-m-d or d/m/y or m/d/y :-(
  dt <- dt[, c("date_char1","date_char2", "date_char3") := data.table::tstrsplit(date_char, "/")]
  # if this split failed then tstrsplit puts the dateVar in each one so we can check
  # and then split on / instead
  dt <- dt[date_char1 == date_char2, c("date_char1","date_char2", "date_char3") := data.table::tstrsplit(date_char, "-")] # requires data.table

 dt$dateFormat <- "ambiguous"

  if(max(as.integer(dt$date_char3)) > 32){
    # char 3 = year
    if(max(as.integer(dt$date_char2)) > 12){
      # char 2 = day
      dt$dateFormat <- "mdy"
    }
    if(max(as.integer(dt$date_char1)) > 12){
      # char 1 = month
      dt$dateFormat <- "dmy"
    }
  }
  if(max(as.integer(dt$date_char1)) > 32){
    # char 1 = year
    if(max(as.integer(dt$date_char2)) > 12){
      # char 2 = day
      dt$dateFormat <- "ydm"
    }
    if(max(as.integer(dt$date_char1)) > 12){
      # char 1 = month
      dt$dateFormat <- "ymd"
    }
  }
  return(dt)
}





