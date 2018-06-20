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
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk} (original)
#' @export
#'
createSafeFtF <- function(dt){
  safeDT <- dt[, c("Reg No", "Latitude", "Longitude", "Course (deg)") := NULL]
  return(safeDT)
}

#' Creates useful derived variables and returns dt
#'
#' \code{createDerivedFtF} converts the given time periods (TP1 -> TP48, 49. 50) to hh:mm. It ignores
#'  TP49 & TP50 as evil incarnations of DST related clock changes (see https://www.emi.ea.govt.nz/Wholesale/Datasets/Generation/Generation_MD/).
#'  We advise NEVER using the months in which this happens as it will hurt your brain.
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk} (original)
#' @export
#'
createDerivedFtF <- function(dt){
  dt <- dt[, rDate := lubridate::dmy(`Date (GPS)`)]
  dt <- dt[, rTime := hms::parse_hms(`Time (GPS)`)]
  dt <- dt[, rDateTime := lubridate::ymd_hms(paste0(rDate, rTime))] # set full dateTime
  return(dt)
}


