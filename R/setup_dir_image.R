#' Setup Directory for Docker Image
#'
#' Sets up the desired directory with the appropriate file structure for the
#' Docker image and an empty Dockerfile.
#'
#' @inheritParams prepare_docker_image
#' @inheritParams devtools::build
#'
#' @return \code{list} directories and paths for files for Docker image.
#'
#' @importFrom crayon blue yellow
#' @importFrom cli cat_bullet
#' @importFrom pkgload pkg_name pkg_version pkg_path
setup_dir_image <- function(pkg = ".",
                            directory = NULL,
                            overwrite = TRUE,
                            verbose = FALSE) {

  # set root directory to path of package, if it has not been provided by the 
  # user.
  if (is.null(directory)) {
    directory <- dirname(pkg_path(path = pkg))
  }

  # check permissions for directory.
  check_permissions_dir(directory)

  # set full path of docker folder.
  pkgname_pkgvrs <- paste0(pkg_name(path = pkg), "_", pkg_version(path = pkg))
  dir_image <- file.path(directory, pkgname_pkgvrs)

  # check if folder for Docker files is non-empty.
  if (length(list.files(dir_image)) > 0) {
    if (!overwrite) {
      stop(dir_image, " already exists and is non-empty. If you want to",
           " overwrite this directory, set 'overwrite' to TRUE.")
    } else {
      # delete folder for Docker files.
      unlink(dir_image, recursive = TRUE)
      if (verbose) {
        cat_bullet("Deleting existing folder for files for Docker image: ", blue(dir_image),
                   bullet = "tick",
                   bullet_col = "green")
      }
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

  # create docker folder.
  dir.create(dir_source_packages)
  if (verbose) {
    cat_bullet("Creating folder for source packages: ", blue(dir_source_packages),
               bullet = "tick",
               bullet_col = "green")
  }

  # set path to Docker file.
  path_Dockerfile <- file.path(dir_image, "Dockerfile")

  # create empty Dockerfile.
  file.create(path_Dockerfile)
  if (verbose) {
    cat_bullet("Creating empty Dockerfile: ", blue(path_Dockerfile),
               bullet = "tick",
               bullet_col = "green")
  }

  # combine meta data for Docker files.
  meta_data <- list(dir_image = dir_image,
                    path_Dockerfile = path_Dockerfile,
                    dir_source_packages = dir_source_packages,
                    pkgname_pkgvrs = pkgname_pkgvrs)
  
  # return meta_data invisibly.
  invisible(meta_data)

}



