#' Identify Package Dependencies
#'
#' @inheritParams gtools::getDependencies
#'
#' @return \code{character} all dependencies.
#'
#' @importFrom gtools getDependencies
identify_dependencies <- function(dependencies = c("Depends", "Imports", "LinkingTo"),
                                  installed = TRUE,
                                  available = TRUE,
                                  base = FALSE,
                                  recommended = FALSE) {

  # get package name.
  pkg_name <- pkgload::pkg_name()

  # get dependencies.
  gtools::getDependencies(pkgs = pkg_name,
                          dependencies = dependencies,
                          installed = installed,
                          available = available,
                          base = base,
                          recommended = recommended)

  }
