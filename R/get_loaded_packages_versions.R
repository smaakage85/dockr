#' Get Version Numbers of Loaded Packages
#'
#' @importFrom utils sessionInfo
get_loaded_packages_versions <- function(pkgs) {
  
  # get information about loaded package versions in session.
  pkgs_loaded_info <- sessionInfo()$loadedOnly

  # what packages are loaded?
  pkgs_loaded <- pkgs[pkgs %in% names(pkgs_loaded_info)]
  
  if (length(pkgs_loaded) > 0) {
    # look up version number(s) of loaded package(s).
    pkgs_loaded_versions <- vapply(pkgs_loaded, 
                                   function(x) {pkgs_loaded_info[[x]][["Version"]]},
                                   FUN.VALUE = character(1),
                                   USE.NAMES = TRUE)
  
    # create data.frame with this information.
    pkgs_loaded_df <- data.frame(pkg = pkgs_loaded, 
                                 vrs = pkgs_loaded_versions, 
                                 stringsAsFactors = FALSE,
                                 row.names = NULL)
    } else {
      pkgs_loaded_df <- NULL
    }
  
  # what packages are installed but not loaded?
  pkgs_installed <- pkgs[!pkgs %in% names(pkgs_loaded_info)]
  
  if (length(pkgs_installed) > 0) {
    # get information about installed packages.
    pkgs_installed_info <- as.data.frame(installed.packages(), 
                                         stringsAsFactors = FALSE)
  
    # look up version number(s) packages installed, but not loaded.
    pkgs_installed_versions <- vapply(pkgs_installed, function(x) {
      version <- pkgs_installed_info[pkgs_installed_info$Package == x, "Version"]
      # pick first version (on search path)
      version[[1]]},
      FUN.VALUE = character(1))
  
    # create data.frame with this information.
    pkgs_installed_df <- data.frame(pkg = pkgs_installed, 
                                    vrs = pkgs_installed_versions, 
                                    stringsAsFactors = FALSE,
                                    row.names = NULL)
  } else {
    pkgs_installed_df <- NULL
  }
  
  # bind installed and loaded package versions together.
  rbind(pkgs_loaded_df, pkgs_installed_df)
  
}
