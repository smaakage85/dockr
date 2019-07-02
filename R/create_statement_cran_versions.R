#' Create Install CRAN Packages Statement for Dockerfile
#'
#' @param deps \code{data.frame} dependency packages with version numbers.
#' @inheritParams prepare_docker_image
#'
#' @return \code{character} statement for Dockerfile.
create_statement_cran_versions <- function(deps, verbose = TRUE) {

  # handle case, when there are no CRAN deps.
  if (is.null(deps)) {
    return(NULL)
  }

  # create install statements for all packages.
  statement <- mapply(FUN = paste0,
                      "RUN R -e 'remotes::install_version(\"",
                      deps$pkg,
                      "\", \"",
                      deps$vrs,
                      "\", dependencies = FALSE)'",
                      USE.NAMES = FALSE, SIMPLIFY = TRUE)

  # combine into one statement.
  statement <- c("# install specific versions of CRAN packages from MRAN snapshots",
                 "RUN R -e 'install.packages(\"remotes\")'",
                 statement,
                 "")

  # print service information.
  if (verbose) {
    cat_bullet("Preparing install statements for specific versions of CRAN packages",
               bullet = "tick",
               bullet_col = "green") 
  }

  # return statement.
  statement

}
