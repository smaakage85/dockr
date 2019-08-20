#' Build, Install and Load Package
#'
#' Builds, installs and loads the package. In addition the source package
#' is saved in the directory with the files for the Docker image.
#'
#' @inheritParams prepare_docker_image
#' @inheritParams devtools::build
#'
#' @param dir_source_packages \code{character} directory containing the 
#' specific local source packages, that will be included in the Docker container
#'  image.
#' @param pkgname_pkgversion \code{character} the package name concatenated
#' with the version number of the package.
#'
#' @return invisibly. The package is built, installed and loaded as side 
#' effects. Furthermore the source package is saved in the folder containing 
#' the files for the Docker image.
#'
#' @importFrom devtools document build
#' @importFrom utils install.packages
build_and_install_package <- function(pkg = ".",
                                      dir_source_packages,
                                      pkgname_pkgversion,
                                      verbose = FALSE) {

  if (verbose) {
    cat_bullet("Building, installing and loading package...",
               bullet = "em_dash",
               bullet_col = "gray")
  }

  # create documentation.
  document(pkg = pkg,
           roclets = c('rd', 'collate', 'namespace'))

  # build package and save in folder for source packages.
  build(pkg = pkg,
        path = dir_source_packages,
        binary = FALSE,
        quiet = TRUE,
        vignettes = FALSE)

  # install package.
  install.packages(pkgs = paste0(file.path(dir_source_packages, pkgname_pkgversion), ".tar.gz"),
                   lib = tempdir(),
                   repos = NULL)

  # return invisibly.
  invisible(NULL)

}


