#' Setup Directory for Docker Image
#'
#' Prepares the desired directory with the appropriate file structure for the
#' Docker image and an empty Dockerfile.
#'
#' @inheritParams prepare_docker_image
#'
#' @return \code{list} directories and paths for Docker files.
#'
#' @importFrom crayon blue yellow
#' @importFrom cli cat_bullet
#' @importFrom pkgload pkg_name pkg_version pkg_path
setup_dir_image <- function(directory = NULL,
                            verbose = FALSE) {

  # expand directory.
  if (is.null(directory)) {
    directory <- dirname(pkg_path())
  }

  # check permissions for directory.
  check_permissions_dir(directory)

  # set full path of docker folder.
  pkgname_pkgvrs <- paste0(pkg_name(), "_", pkg_version())
  dir_image <- file.path(directory, pkgname_pkgvrs)

  # check if folder for Docker files is non-empty.
  if (length(list.files(dir_image)) > 0) {
    if (verbose) {
      cat_bullet("Folder: ", blue(dir_image), " already exists and is non-empty. ", yellow("Proceed with care!"),
                 bullet = "warning",
                 bullet_col = "yellow")
    }
  }

  # create folder for Docker files.
  if (!dir.exists(dir_image)) {
    dir.create(dir_image)
    if (verbose) {
      cat_bullet("Creating folder for files for Docker image: ", blue(dir_image),
                 bullet = "tick",
                 bullet_col = "green")
    }
  }

  # set full path of docker folder.
  dir_source_packages <- file.path(dir_image, "source_packages")

  # check if folder for source packages exists.
  if (dir.exists(dir_source_packages)) {
    unlink(dir_source_packages, recursive = TRUE)
    if (verbose) {
      cat_bullet("Deleting existing folder for source packages: ", blue(dir_source_packages),
                 bullet = "tick",
                 bullet_col = "green")
    }

  }

  # create docker folder.
  dir.create(dir_source_packages)
  if (verbose) {
    cat_bullet("Creating folder for source packages: ", blue(dir_source_packages),
               bullet = "tick",
               bullet_col = "green")
  }

  # set path to Docker file.
  path_Dockerfile <- file.path(dir_image, "Dockerfile")

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
  invisible(list(dir_image = dir_image,
                 path_Dockerfile = path_Dockerfile,
                 dir_source_packages = dir_source_packages,
                 pkgname_pkgvrs = pkgname_pkgvrs))

}



