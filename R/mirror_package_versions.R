#' Mirror Version Numbers of Loaded and Installed Packages
#'
#' Mirrors version numbers of specific packages. If a package is loaded, the
#' version number of the loaded package is used. If a packages is not loaded but
#' installed, the version number of the installed package will be extracted
#' in stead.
#'
#' @param pkgs \code{character} names of packages.
#'
#' @return \code{data.frame} with package names and their relevant version 
#' numbers.
#'
#' @importFrom utils sessionInfo installed.packages packageDescription
mirror_package_versions <- function(pkgs) {

  # handle case, when there are no packages.
  if (is.null(pkgs)) {
    return(NULL)
  }

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
    pkgs_installed_info <- lapply(pkgs_installed, identify_installed_version)
    pkgs_installed_info <- do.call(rbind, pkgs_installed_info)

    # look up version number(s) packages installed, but not loaded.
    pkgs_installed_versions <- vapply(pkgs_installed, function(x) {
      version <- pkgs_installed_info[pkgs_installed_info$Package == x, "Version"]
      # pick first version (there should only be one)
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
  pkg_vrs_df <- rbind(pkgs_loaded_df, pkgs_installed_df)

  # check if all dependency packages have been matched with a version number.
  not_matched <- pkgs[!pkgs %in% pkg_vrs_df$pkg]
  if (length(not_matched) > 0) {
    stop("One or more dependency packages were not loaded or installed. ",
         "Please install packages: ",
         paste0(not_matched, collapse = ", "))
  }

  # return dependencies with version numbers in data.frame.
  pkg_vrs_df

}

# Find out what version of a given package, that is installed. Helper function.
identify_installed_version <- function(pkg_name) {
  
  # look up package description.
  package_description <- suppressWarnings(packageDescription(pkg_name))
  
  # handle case, where package is not installed.
  if (!is.list(package_description)) {
    return(data.frame(Package = NULL, Version = NULL, stringsAsFactors = FALSE))
  }
  
  data.frame(Package = pkg_name, Version = package_description$Version,
             stringsAsFactors = FALSE)
  
} 

