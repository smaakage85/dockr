#' Identify R Package Dependencies of Package
#'
#' Identifies the R package dependencies of a package and the version numbers of
#' the corresponding packages, that are currently loaded or installed.
#'
#' @inheritParams gtools::getDependencies
#' @inheritParams prepare_docker_image
#'
#' @importFrom pkgload pkg_name
#' @importFrom gtools getDependencies
#'
#' @return \code{list} with dependencies ordered recursively and a data.frame
#' with all R package dependencies with version numbers of the corresponding (1)
#' loaded or (2) installed packages.
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
    message("No R package dependencies detected. Docker container image will",
            " be trivial.")
    return(NULL)
  }

  # mirror loaded (and installed) version numbers of all dependency R packages.
  deps_mirror <- mirror_package_versions(deps)

  # print service information.
  if (verbose) {
    cat_bullet("Identifying and mirroring R package dependencies",
               bullet = "tick",
               bullet_col = "green")
  }

  # return R package dependencies with version numbers.
  list(deps_recursively = deps, deps_mirror = deps_mirror)

}
