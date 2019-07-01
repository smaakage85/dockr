#' Create Install Statements for Local Source Packages
#'
#' @param pkgs_df \code{data.frame} with names and version numbers of desired
#' packages.
#' @inheritParams prepare_docker_image
#' @inheritParams match_pkg_local
#'
#' @return \code{character} install chunk for Dockerfile.
create_statement_local_pkgs <- function(pkgs_df,
                                        dir_src_docker = "",
                                        verbose = TRUE) {

  # handle case, when no local dependencies are required.
  if (is.null(pkgs_df) || nrow(pkgs_df) == 0) {
    return(NULL)
  }

  # create install statements.
  statements <- mapply(
    FUN = function(pkg, vrs) {

      # create source package file name.
      fn <- paste0(pkg, "_", vrs, ".tar.gz")

      # create install statements.
      statement <- paste0("RUN R -e 'install.packages(pkgs = \"", fn, "\", repos = NULL)'")

    },
    pkg = pkgs_df$pkg, vrs = pkgs_df$vrs, SIMPLIFY = FALSE, USE.NAMES = FALSE)

  # convert to one character vector.
  statements <- do.call(c, statements)

  # combine into one statement.
  statements <- c("# install local source packages",
    statements,
    "")

  # print service information.
  if (verbose) {
    cat_bullet("Preparing install statements for local source packages",
               bullet = "tick",
               bullet_col = "green")
  }

  statements


}
