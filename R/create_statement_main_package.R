#' Create Install Statement for Main Package
#'
#' @param dir_source_packages \code{character} directory of subfolder with
#' relevant source packages for a Docker image.
#' @param pkgname_pkgversion \code{character} package name and package version
#' number for main package - concatenated.
#' @inheritParams prepare_docker_image
#'
#' @return \code{character} chunk with install statement for Dockerfile.
create_statement_main_package <- function(dir_source_packages,
                                          pkgname_pkgversion,
                                          verbose = TRUE,
                                          pkg = pkg) {

  # create source package filepath as character.
  fp <- paste0(file.path("source_packages", pkgname_pkgversion), ".tar.gz")

  # create install statement.
  statement <- paste0("RUN R -e 'install.packages(pkgs = \"", fp, "\", repos = NULL)'")

  # combine into one statement.
  statement <- c(paste0("# install '", pkg_name(pkg), "' package"),
    statement,
    "")

  if (verbose) {
    cat_bullet("Preparing install statement for the package itself",
               bullet = "tick",
               bullet_col = "green")
  }

  statement

}
