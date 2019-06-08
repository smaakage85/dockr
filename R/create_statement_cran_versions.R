create_statement_cran_versions <- function(deps) {

  # create install statements for all packages.
  statement <- mapply(FUN = paste0,
                      "RUN R -e 'remotes::install_version(\"",
                      deps$pkg,
                      "\", \"",
                      deps$vrs,
                      "\")'",
                      USE.NAMES = FALSE, SIMPLIFY = TRUE)

  # combine into one statement.
  c("# install specific versions of packages from CRAN",
    "RUN R -e 'install.packages(\"remotes\")'",
    statement,
    "")

}
