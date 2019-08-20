#' Set Library Paths Temporarily
#'
#' @param dir_install \code{character} where should the package be installed
#' on your system. Choose from `auto` (automatic detection), `temp` 
#' (temporary directory) or specify directory yourself.
#'
#' @return invisibly. Sets the library paths temporarily as a side effect. 
#' This will determine, where the package is installed.
set_lib_paths <- function(dir_install) {
  
  # Check, if directory has been actually provided.
  if (is.null(dir_install)) {
    stop("Please provide directory, where the package will be installed.",
         "Choose from 'auto' (automatic detection), 'temp' (temporary directory) ",
         "or specify directory yourself.")
  }
  
  # Check, if directory is character and has a length of 1.
  if (!is.character(dir_install)) {
    stop("'dir_install' must be a directory (character)")
  }
  
  if (length(dir_install) != 1) {
    stop("'dir_install' must have length of 1.")
  }
  
  # set directory to tempdir if relevant.
  if (dir_install == "temp") {
    dir_install <- tempdir()
  }
  
  if (!dir.exists(dir_install)) {
    stop("'dir_install' does not exist.")
  }
  
  # modify lib paths.
  if (dir_install %in% "temp" || dir_install != "auto") {
    
    # modify library paths temporarily (to install package and look up 
    # dependencies).
    .libPaths(append(dir_install, .libPaths()))
    
  }
  
  invisible(NULL)
  
}