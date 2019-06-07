write_dockerfile <- function() {

  # prep docker folders and files.
  paths <- prep_docker()

  # build and load package.
  folder_source_packages <- paths$folder_source_packages
  cat_bullet("Building and loading package...",
             bullet = "en_dash",
             bullet_col = "gray")
  suppressMessages(build_and_load_package(folder_source_packages))

  # identify package dependencies.
  pkg_deps <- identify_dependencies()
  cat_bullet("Identifying package dependencies",
             bullet = "tick",
             bullet_col = "green")

  # open connection to Dockerfile.
  path_Dockerfile <- paths$path_Dockerfile
  Dockerfile <- file(path_Dockerfile)

  # write Dockerfile.
  cat_bullet("Writing Dockerfile...",
             bullet = "en_dash",
             bullet_col = "gray")

  # write FROM statement.
  FROM_statement <- c("# load rocker r-base image",
                      set_rocker_image(),
                      "")
  writeLines(FROM_statement, Dockerfile)
  cat_bullet("Writing FROM statement to Dockerfile",
             bullet = "tick",
             bullet_col = "green")

  cat_bullet("Closing Dockerfile.",
             bullet = "tick",
             bullet_col = "green")

  # close connection to Dockerfile.
  close(Dockerfile)

  # return invisibly.
  invisible(NULL)

}
