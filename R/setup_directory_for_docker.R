#' Setup Directory for Docker Image
#'
#' Prepares the desired directory with the appropriate file structure for the
#' Docker image.
#'
#' @inheritParams prepare_docker_image
#'
#' @return \code{list} directories and paths for Docker files.
#'
#' @importFrom crayon blue yellow
#' @importFrom cli cat_bullet
#' @importFrom pkgload pkg_name pkg_version pkg_path
setup_directory_for_docker <- function(directory = NULL,
                                       verbose = FALSE) {

  # expand directory.
  if (is.null(directory)) {
    directory <- dirname(pkg_path())
  }

  # check permissions for directory.
  check_permissions_dir(directory)

  # set full path of docker folder.
  pkgname_pkgvrs <- paste0(pkg_name(), "_", pkg_version())
  folder_docker <- file.path(directory, pkgname_pkgvrs)

  # check if folder for Docker files is non-empty.
  if (length(list.files(folder_docker)) > 0) {
    if (verbose) {
      cat_bullet("Folder: ", blue(folder_docker), " already exists and is non-empty. ", yellow("Proceed with care!"),
                 bullet = "warning",
                 bullet_col = "yellow")
    }
  }

  # create folder for Docker files.
  if (!dir.exists(folder_docker)) {
    dir.create(folder_docker)
    if (verbose) {
      cat_bullet("Creating folder for Docker files: ", blue(folder_docker),
                 bullet = "tick",
                 bullet_col = "green")
    }
  }

  # set full path of docker folder.
  folder_source_packages <- file.path(folder_docker, "source_packages")

  # check if folder for source packages exists.
  if (dir.exists(folder_source_packages)) {
    unlink(folder_source_packages, recursive = TRUE)
    if (verbose) {
      cat_bullet("Deleting existing folder for source packages: ", blue(folder_source_packages),
                 bullet = "tick",
                 bullet_col = "green")
    }

  }

  # create docker folder.
  dir.create(folder_source_packages)
  if (verbose) {
    cat_bullet("Creating folder for source packages: ", blue(folder_source_packages),
               bullet = "tick",
               bullet_col = "green")
  }

  # set path to Docker file.
  path_Dockerfile <- file.path(folder_docker, "Dockerfile")

  # delete any existing Dockerfile.
  if (file.exists(path_Dockerfile)) {
    file.remove(path_Dockerfile)
    if (verbose) {
      cat_bullet("Deleting existing Dockerfile: ", blue(path_Dockerfile),
                 bullet = "tick",
                 bullet_col = "green")
    }
  }

  # create empty Dockerfile.
  file.create(path_Dockerfile)
  if (verbose) {
    cat_bullet("Creating empty Dockerfile: ", blue(path_Dockerfile),
               bullet = "tick",
               bullet_col = "green")
  }


  # return invisibly.
  invisible(list(folder_docker = folder_docker,
                 path_Dockerfile = path_Dockerfile,
                 folder_source_packages = folder_source_packages,
                 pkgname_pkgvrs = pkgname_pkgvrs))

}



