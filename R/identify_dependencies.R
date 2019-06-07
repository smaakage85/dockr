#' Identify Package Dependencies
#'
#' @inheritParams gtools::getDependencies
#'
#' @return \code{data.frame} all dependencies with version numbers of
#' the corresponding loaded packages.
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
  deps <- getDependencies(pkgs = pkg_name,
                          dependencies = dependencies,
                          installed = installed,
                          available = available,
                          base = base,
                          recommended = recommended)

  if (length(deps) == 0) {
    warning("No non-base dependencies detected. This will not be an",
            " interesting Docker image..")
    return(NULL)
  }

  # get (loaded) versions of all dependency packages.
  get_loaded_packages_versions(deps)

}
