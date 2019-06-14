create_statement_local_pkgs <- function(pkgs_df,
                                        dir_src_docker = "/home/w19799@CCTA.DK/projects/dockr_0.8.0/source_packages/") {

  # handle case, when no local dependencies are required.
  if (is.null(pkgs_df)) {
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
  c("# install local source packages",
    statements,
    "")

}
