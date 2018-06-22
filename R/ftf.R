# Functions for flipTheFleet data processing

#' Removes disclosive variables
#'
#' \code{createSafeFtF} removes the following disclosive variables:
#'  `Reg No`
#'  `Latitude`
#'  `Longitude`
#'  `Course (deg)`
#'
#'  Ideally these would be removed prior to sharing the data.
#'
#' @import data.table
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk} (original)
#' @export
#'
createSafeFtF <- function(dt){
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
  dt <- dt[, evID := openssl::md5(`Reg No`)] # hash
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
  dt <- homeMinLat <- dt[, homeMinLat := min(dt[obsHour > 1 & obsHour < 5]$Latitude), by = .(evID)] # do this for each value of evID so bbox is different for each one
  dt <- homeMaxLat <- dt[, homeMaxLat := max(dt[obsHour > 1 & obsHour < 5]$Latitude), by = .(evID)]
  dt <- homeMinLon <- dt[, homeMinLon := min(dt[obsHour > 1 & obsHour < 5]$Longitude), by = .(evID)]
  dt <- homeMinLon <- dt[, homeMaxLon := max(dt[obsHour > 1 & obsHour < 5]$Longitude), by = .(evID)]

  dt <- dt[, geoLoc := ifelse((Latitude >= homeMinLat & Latitude <= homeMaxLat) &
                                (Longitude >= homeMinLon & Longitude <= homeMaxLon), "Home", "Not home"), # set home if within bb at any time
           by = .(evID)]
  return(dt)
}

#' Draws map of all locations (without sampling)
#'
#' \code{getEVMap} Draws map pf all observations without sampling via the GPS Lat/Long. Observations without GPS co-ords (and thus time/date won't be mapped)
#'
#' @import ggmap
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk} (original)
#' @export
#'
getEVMap <- function(dt){
  # get the bounding box for the data
  bb <- ggmap::make_bbox(Longitude, Latitude, data = ftfDT)
  # get the map for the bounding box - lots of base map options are available - see ?ggmap
  myMap <- ggmap::ggmap(ggmap::get_map(location = bb), maprange = TRUE)
  # create the map
  evMap <- myMap + # use qmap's geolocator function
    geom_point(aes(x = Longitude, y = Latitude, colour = `Speed (GPS)`), # colour by speed :-)
               data = dt,
               shape = 4,
               size = 1,
               alpha = 0.4
    )
  # qmap will grab the google overlap for us by default so this will fail if we are offline
  # over-ride the source using source = , overide type using maptype =
  # see ?qmap
  return(evMap) # <- this is a ggplot type map so you can add annotations using ggplot e.g. average speed :-)
}

