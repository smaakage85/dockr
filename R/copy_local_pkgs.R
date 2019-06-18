#' Copy Local Source Packages to Docker Subdirectory
#' 
#' @param pkgs_df \code{data.frame} with names and version numbers of packages
#' to be copied to Docker subdirectory.
#'
#' @param dir_src_docker \code{character} directory of subfolder with
#' relevant source packages for a Docker image. Source packages will be copied
#' to this directory. 
#' @inheritParams prepare_docker_image
#'
#' @return invisibly. As a side effect source package files (*.tar.gz) are 
#' copied to Docker subdirectory.
#' 
#' @importFrom pbapply pbmapply
copy_local_pkgs <- function(pkgs_df = NULL,
                            dir_src = NULL,
                            dir_src_docker = NULL,
                            verbose = TRUE) {

  # handle case, when there are no dependencies.
  if (is.null(pkgs_df)) {
    # return invisibly.
    return(invisible(NULL))
  }

  # copy packages.
  pbmapply(
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
