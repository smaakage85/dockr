match_pkg_local <- function(pkgs_df = data.frame(pkg = c("recorder", "modelgrid"),
                                                  vrs = c("0.8.1", "1.1.0"),
                                                  stringsAsFactors = FALSE),
                            dir_src = "/home/w19799@CCTA.DK/projects/",
                            dir_src_docker = "/home/w19799@CCTA.DK/projects/dockr_0.8.0/source_packages/") {

  # handle case, when there are no dependencies.
  if (is.null(pkgs_df)) {
    return(NULL)
  }

  # handle case, where no source package directories exist.
  if (is.null(dir_src)) {
    return(NULL)
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

  # move .tar.gz file to Docker source packages folder.
  # file.copy(file.path(dir_src, pkg_file), dir_src_docker)

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

  # subset packages, that are in files.
  pkgs_df <- pkgs_df[are_in_files, ]

  pkgs_df

}
