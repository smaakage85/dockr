#' Get Version Numbers of Loaded Packages
get_loaded_packages_versions <- function(pkgs) {

  # look up version number(s) of corresponding loaded package(s).
  versions <- vapply(pkgs, function (x) {as.character(packageVersion(x))},
                     FUN.VALUE = character(1))

  # combine dependencies with version numbers in data.frame.
  data.frame(pkg = pkgs, vrs = versions, stringsAsFactors = FALSE,
             row.names = NULL)

}
