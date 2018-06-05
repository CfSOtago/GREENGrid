#' Loads gridSpy meta data from .xlsx
#'
#' \code{gertMetaData} does what it says. Expects .xlsx with two sheets, one for each sample.
#'
#' Combines the results into one table
#'
#' @param f the .xlsx file
#'
#' @import data.table
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk}
#' @export
#'
#'
getMetaData <- function(f) {
  unisonDT <- data.table::as.data.table(readxl::read_xlsx(f, sheet = "Unison"))

  # keep safe data only
  unisonDT <- unisonDT[, .(sample = `Power company`, hhID = `Tag`,
                           Adults,Teenagers,Children,removed )]
  #head(unisonDT)

  powercoDT <- data.table::as.data.table(readxl::read_xlsx(f, sheet = "Powerco"))
  powercoDT <- powercoDT[, .(sample = `Power Co`, hhID = `Building Tag`,
                             Adults = `Adult`,Teenagers,Children, removed = `date disconnected` )]
  #head(powercoDT)

  # remove NA on rbind
  dt <- rbind(unisonDT, powercoDT[!is.na(hhID)])
  return(dt)
}
