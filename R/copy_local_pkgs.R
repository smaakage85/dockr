#' @importFrom pbapply pbmapply
copy_local_pkgs <- function(pkgs_df = NULL,
                            dir_src = "/home/w19799@CCTA.DK/projects/",
                            dir_src_docker = "/home/w19799@CCTA.DK/projects/dockr_0.8.0/source_packages/") {

  # handle case, when there are no dependencies.
  if (is.null(pkgs_df)) {
    # return invisibly.
    return(invisible(NULL))
  }

  # copy packages.
  mapply(
    FUN = copy_local_pkgs_helper,
    pkg = pkgs_df$pkg,
    vrs = pkgs_df$vrs,
    dir = pkgs_df$source,
    dir_src_docker = dir_src_docker
  )

  # return invisibly.
  return(invisible(NULL))

}

copy_local_pkgs_helper <- function(pkg, vrs, dir, dir_src_docker) {

  # create source package file name.
  paste0(pkg, "_", vrs, ".tar.gz")

  # create complete source package file path.
  fp <- file.path(dir, paste0(pkg, "_", vrs, ".tar.gz"))

  # move .tar.gz files to Docker source packages folder.
  file.copy(fp, dir_src_docker, overwrite = TRUE)

  # return invisibly.
  return(invisible(NULL))

}
