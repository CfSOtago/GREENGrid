#' Get list of grid spy data files
#'
#' \code{getFileList} takes a path and a pattern and recursively searches for data files in that path (and folders within it)
#' whose file names match the pattern.
#'
#' Use the pattern to extract e.g : 1 min files (*at1.csv$) vs 1 second files etc
#'
#' Returns the file list as a data.table with col name = `fList`. If no files are found returns a NULL dt
#'
#' @param path the path to search
#' @param pattern the pattern to search within path
#'
#' @importFrom data.table as.data.table
#'
#' @author Ben Anderson, \email{b.anderson@@soton.ac.uk}
#' @export
#'
getFileList <- function(fpath, pattern) {
  print(paste0("Looking for data using pattern = ", pattern, " in ", fpath, " - could take a while..."))
  fList <- list.files(path = fpath, pattern = pattern, # use to filter e.g. 1m from 30s files
                      recursive = TRUE)
  if(length(fList) == 0){ # if there are no files in the list...
    print(paste0("No matching data files found, please check your path (", fpath, ") or your search pattern (", pattern, ")"))
    dt <- data.table::as.data.table(NULL)
  } else {
    dt <- data.table::as.data.table(fList) # the column name will be fList
  }
  return(dt)
}

