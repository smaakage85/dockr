combine_deps <- function(pkg_deps, deps_cran, deps_local, prioritize_cran = FALSE) {

  # handle case, when there are no dependencies.
  if (is.null(pkg_deps)) {
    return(NULL)
  }

  # which packages are matched?
  pkg_match <- c(deps_cran$pkg, deps_local$pkg)
  # which packages were not matched?
  pkg_no_match <- pkg_deps[!pkg_deps$pkg %in% pkg_match, c("pkg", "vrs")]
  # handle case, when one or more packages were not found.
  if (nrow(pkg_no_match) > 0) {
    stop("The following dependency packages were not found on CRAN or in local directories: \n",
         paste(pkg_no_match$pkg, pkg_no_match$vrs, sep = "_", collapse = ", "))
  }

  # identify any overlap of packages between CRAN and local directories.
  pkg_overlap <- deps_cran[deps_cran$pkg %in% deps_local$pkg, c("pkg", "vrs")]
  if (length(pkg_overlap) > 0) {
    message("The following dependency packages were found both on CRAN and in local directories: \n",
            paste(pkg_overlap$pkg, pkg_overlap$vrs, sep = "_", collapse = ", "))
    if (prioritize_cran) {
      message("CRAN packages will be prioritized (change this choice with argument 'prioritize_cran').")
      # remove redundant dependencies from local dependencies.
      deps_local <- deps_local[!deps_local$pkg %in% pkg_overlap$pkg, ]
    } else {
      message("Local source packages will be prioritized (change this choice with argument 'prioritize_cran').")
      # remove redundant dependencies from local dependencies.
      deps_cran <- deps_cran[!deps_cran$pkg %in% pkg_overlap$pkg, ]
    }
  }

  # return as list with elements for CRAN and non-CRAN dependencies respectively.
  list(deps_cran = deps_cran, deps_local = deps_local)

}
