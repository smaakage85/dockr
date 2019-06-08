#' @importFrom devtools document build
#' @importFrom remotes install_local
build_and_install_package <- function(folder_source_packages, pkgname_pkgversion) {

  # create documentation.
  document(roclets = c('rd', 'collate', 'namespace'))

  # build package in folder for source packages.
  build(path = folder_source_packages, binary = FALSE, quiet = TRUE)

  # install package.
  install.packages(paste0(file.path(folder_source_packages, pkgname_pkgversion), ".tar.gz"),
                   repos = NULL)

  # return invisibly.
  invisible(NULL)

}

