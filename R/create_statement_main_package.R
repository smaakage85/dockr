create_statement_main_package <- function(folder_source_packages, 
                                          pkgname_pkgversion) {
  
  # create source package filepath as character.
  fp <- paste0(file.path("source_packages", pkgname_pkgversion), ".tar.gz")
  
  # create install statement.
  statement <- paste0("RUN R -e 'install.packages(pkgs = \"", fp, "\", repos = NULL)'")
  
  # combine into one statement.
  c("# make directory for source packages (*.tar.gz)",
    "COPY source_packages /source_packages",
    "",
    paste0("# install '", pkg_name(), "' package"),
    statement,
    "",
    "# load package",
    paste0("RUN R -e 'library(\"", pkg_name(), "\")'"))
  
}
