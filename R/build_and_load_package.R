#' @importFrom devtools document build
build_and_load_package <- function(folder_source_packages) {

  # create documentation.
  document(roclets = c('rd', 'collate', 'namespace'))

  # build package in folder for source packages.
  build(path = folder_source_packages, binary = FALSE)

  # return invisibly.
  invisible(NULL)

}
