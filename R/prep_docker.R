#' Prepare Docker folder
#'
#' Prepares Docker folder in package directory.
#' 
#' @return \code{list} directories and paths for Docker files.
#' 
#' @importFrom cli cat_bullet
#' @importFrom pkgload pkg_name pkg_version
prep_docker <- function(directory = "~") {

  # expand directory.
  directory <- path.expand(directory)

  # set full path of docker folder.
  docker_folder <- file.path(directory, paste0(pkg_name(), "_", pkg_version()))

  # check if folder already exists and is non-empty.
  if (length(list.files(docker_folder)) > 0) {
    cat_bullet(paste0(docker_folder, " already exists and is non-empty. Proceed with care."), 
               bullet = "warning", 
               bullet_col = "yellow")
  }
  
  # create docker folder.
  if (!dir.exists(docker_folder)) {
    dir.create(docker_folder)
    cat_bullet(paste0("Creating folder for Docker files:", docker_folder), 
               bullet = "tick", 
               bullet_col = "green")
  }
  
  # set path to Docker file.
  Dockerfile_path <- file.path(docker_folder, "Dockerfile")
  
  # delete any existing Dockerfile.
  if (file.exists(Dockerfile_path)) {
    file.remove(Dockerfile_path)
    cat_bullet(paste0("Delete existing Dockerfile: ", Dockerfile_path), 
               bullet = "tick", 
               bullet_col = "green")
  }
  
  # create empty Dockerfile.
  file.create(Dockerfile_path)
  cat_bullet(paste0("Creating empty Dockerfile: ", Dockerfile_path), 
             bullet = "tick", 
             bullet_col = "green")
  
  # return invisibly.
  invisible(list(docker_folder = docker_folder,
                 Dockerfile_path = Dockerfile_path))

}


