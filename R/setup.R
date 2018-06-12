#' Sets a range of parameters re-used throughout the repo
#'
#' \code{setup} sets a range of parameters including data sources and .Rmd include locations. It returns these as a list.
#'
#'   The parameters can be over-written in scipts if needed but do so wih care!
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk} (original)
#' @export
#'
setup <- function(){
  p <- list() # params holder
  p$projLoc <- nzGREENGrid::findParentDirectory("nzGREENGrid") # R project location
  p$dataLoc <- "/Volumes/hum-csafe/Research Projects/GREEN Grid/" # HPS by default

  p$historyGenericRmd <- paste0(p$projLoc, "/includes/historyGeneric.Rmd")
  p$supportGenericRmd <- paste0(p$projLoc, "/includes/supportGeneric.Rmd")
  p$pubLoc <- "[Centre for Sustainability](http://www.otago.ac.nz/centre-sustainability/), University of Otago: Dunedin."

  return(p) #
}
