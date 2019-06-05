#' Set Rocker Image
#' 
#' Set rocker image to reflect desired version of R.
#'
#' @param r_version \code{character} desired version of R. If NULL, the active
#' version of R will be used.
#'
#' @return \code{character} string with FROM statement for Dockerfile.
#' @export
set_rocker_image <- function(r_version = NULL) {
  
  # get R version number.
  if (is.null(r_version)) {
    r_version <- strsplit(R.Version()[['version.string']], ' ')[[1]][3]
  }
  
  sprintf("FROM rocker/r-ver:%s", r_version)
  
}