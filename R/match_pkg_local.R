#' Match Package with Local Source Packages
#'
#' @param pkgs_df \code{data.frame} with packages and their respective version
#' numbers to be matched.
#' @param dir_src_docker \code{character} directory of subfolder with
#' relevant source packages for a Docker image. Source packages will be copied
#' to this directory.
#'
#' @inheritParams prepare_docker_image
#'
#' @importFrom pkgload pkg_path
#'
#' @return \code{data.frame} with packages, their version numbers and the
#' directory, where the source package was found.
match_pkg_local <- function(pkgs_df = NULL,
                            dir_src = NULL,
                            dir_src_docker = NULL,
                            verbose = TRUE) {

  # handle case, when there are no dependencies.
  if (is.null(pkgs_df)) {
    return(NULL)
  }

  # look in parent folder of package, if no directory has been provided.
  if (is.null(dir_src)) {
    dir_src <- dirname(pkg_path())
  }

  # look up dependencies in source package directories.
  match_deps <- lapply(dir_src, function(x) {
    match_pkg_local_helper(pkgs_df, x)
    })

  # bind data.frames.
  match_deps <- do.call(rbind, match_deps)

  # if a package is found in more than one directory, use directory with
  # the highest priority.
  match_deps <- match_deps[!duplicated(match_deps[, c("pkg", "vrs")]), ]

  # print service information.
  if (verbose) {
    cat_bullet("Matching dependencies with local source packages",
               bullet = "tick",
               bullet_col = "green")
  }

  match_deps

}

match_pkg_local_helper <- function(pkgs_df, dir_src) {

  # check if dir exists.
  check_permissions_dir(dir_src, existence = TRUE, execute = TRUE, read = TRUE)

  # list files in directory.
  files <- list.files(dir_src)

  # which packages among files?
  pkg_files <- paste0(pkgs_df$pkg, "_", pkgs_df$vrs, ".tar.gz")
  are_in_files <- which(pkg_files %in% files)

  # set column with source.
  pkgs_df$source <- dir_src

  # subset packages, that are found amongst the files.
  pkgs_df <- pkgs_df[are_in_files, ]

  pkgs_df

}
