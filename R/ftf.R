# Functions for flipTheFleet data processing

#' Remove disclosive variables
#'
#' \code{createSafeFtF} creates a new uhnique EV ID byhashing the `Reg No` and then removes the following disclosive variables:
#'  `Reg No`
#'  `Latitude`
#'  `Longitude`
#'  `Course (deg)`
#'
#'  These should be removed prior to any data sharing.
#'
#' @import data.table
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk} (original)
#' @export
#'
createSafeFtF <- function(dt){
  dt <- dt[, evID := openssl::md5(`Reg No`)] # hash the reg number
  safeDT <- dt[, c("Reg No", "Latitude", "Longitude", "Course (deg)") := NULL]
  return(safeDT)
}

#' Creates useful derived variables and returns dt
#'
#' \code{createDerivedFtF} sets proper dates and times for R
#'
#' adds new derived variables to the passed data.table and returns it
#'
#' @import data.table
#' @import lubridate
#' @import hms
#' @import openssl
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk} (original)
#' @export
#'
createDerivedFtF <- function(dt){
  dt <- dt[, rDate := lubridate::dmy(`Date (GPS)`)] # fix date, some will be NA if no GPS signal
  dt <- dt[, rTime := hms::parse_hms(`Time (GPS)`)] # fix Time, some will be NA if no GPS signal
  dt <- dt[, rDateTime := lubridate::ymd_hms(paste0(rDate, rTime))] # set full dateTime
  dt <- dt[, rDow := lubridate::wday(rDate, label = TRUE)]  # set day of the week
  return(dt)
}

#' Infers coarse-grained location (home vs not-home)
#'
#' \code{inferLocationFtF} guesses 'home' by looking at location from 01:00 - 04:00. A future version might try geocoding other locations via lat/long look-up
#'
#'    adds `geoLoc` to the passed data.table and returns it
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk} (original)
#' @export
#'
inferLocationFtF <- function(dt){
  dt <- dt[, obsHour := lubridate::hour(rTime)]
  # could use a fancy bounding box but...
  # find bb for the hours of 01:00 - 05:00: we assume this is 'home'
  dt <- dt[, homeMinLat := min(dt[obsHour > 1 & obsHour < 5]$Latitude), by = .(`Reg No`)] # do this for each value of reg no so bbox is different for each one
  dt <- dt[, homeMaxLat := max(dt[obsHour > 1 & obsHour < 5]$Latitude), by = .(`Reg No`)]
  dt <- dt[, homeMinLon := min(dt[obsHour > 1 & obsHour < 5]$Longitude), by = .(`Reg No`)]
  dt <- dt[, homeMaxLon := max(dt[obsHour > 1 & obsHour < 5]$Longitude), by = .(`Reg No`)]

  dt <- dt[, geoLoc := ifelse((Latitude >= homeMinLat & Latitude <= homeMaxLat) &
                                (Longitude >= homeMinLon & Longitude <= homeMaxLon), "Home", "Not home"), # set home if within bb at any time
           by = .(`Reg No`)]
  return(dt)
}

