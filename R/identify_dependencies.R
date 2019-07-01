#' Identify Package Dependencies
#'
#' Identifies the dependencies of a package and the version numbers of
#' the corresponding packages, that are currently loaded or installed.
#'
#' @inheritParams gtools::getDependencies
#' @inheritParams prepare_docker_image
#'
#' @importFrom pkgload pkg_name
#' @importFrom gtools getDependencies
#'
#' @return \code{data.frame} all dependencies with version numbers of
#' the corresponding (1) loaded or (2) installed packages.
#'
#' @importFrom gtools getDependencies
identify_dependencies <- function(pkg = pkg,
                                  dependencies = c("Depends", "Imports", "LinkingTo"),
                                  base = FALSE,
                                  recommended = FALSE,
                                  verbose = TRUE) {

  # get package name.
  pkg_name <- pkg_name(pkg)

  # get dependencies.
  deps <- getDependencies(pkgs = pkg_name,
                          dependencies = dependencies,
                          installed = TRUE,
                          available = TRUE,
                          base = base,
                          recommended = recommended)

  if (length(deps) == 0) {
    message("No non-base dependencies detected.")
    return(NULL)
  }

  # mirror loaded (and installed) version numbers of all dependency packages.
  loaded_deps <- mirror_package_versions(deps)

  # print service information.
  if (verbose) {
    cat_bullet("Identifying package dependencies",
               bullet = "tick",
               bullet_col = "green")
  }

  # return dependencies with version numbers.
  loaded_deps

}
