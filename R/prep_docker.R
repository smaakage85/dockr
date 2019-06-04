#' Prepare Docker folder
#'
#' Prepares Docker folder in package directory.
#'
#' @importFrom cli cat_bullet
#' @importFrom pkgload pkg_name pkg_version
prep_docker <- function(directory = "~") {

  # expand directory.
  directory <- path.expand(directory)

  # set full path of docker folder.
  docker_folder <- file.path(directory, paste0(pkg_name(), "_", pkg_version()))

  # create docker folder.
  if (!dir.exists(docker_folder)) {
    dir.create(docker_folder)
    cat_bullet(paste0("Creating folder: ", docker_folder), bullet = "tick", bullet_col = "green")
  }

}


