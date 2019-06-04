#' @importFrom usethis use_build_ignore
prep_docker <- function() {

  # create docker folder.
  docker_folder_name <- "docker"
  if (!dir.exists(docker_folder_name)) {
    message("Creating folder: ", docker_folder_name)
    dir.create("docker")
  }

  usethis::use_build_ignore(docker_folder_name)

  invisible(NULL)

}
