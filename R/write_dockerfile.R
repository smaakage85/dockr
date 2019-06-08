#' @export
#'
#' @importFrom crayon cyan silver
write_dockerfile <- function(print_dockerfile = FALSE) {

  # prep docker folders and files.
  paths <- prep_docker()

  # build and load package.
  cat_bullet("Building, installing and loading package...",
             bullet = "em_dash",
             bullet_col = "gray")
  build_and_install_package(paths$folder_source_packages,
                            paths$pkgname_pkgvrs)

  # identify package dependencies.
  pkg_deps <- identify_dependencies()
  cat_bullet("Identifying package dependencies",
             bullet = "tick",
             bullet_col = "green")

  # open connection to Dockerfile.
  Dockerfile <- file(paths$path_Dockerfile)

  # write Dockerfile.
  cat_bullet("Writing Dockerfile...",
             bullet = "em_dash",
             bullet_col = "gray")

  # preparing FROM statement.
  FROM_statement <- c("# load rocker base-R image",
                      set_rocker_image(),
                      "")
  cat_bullet("Preparing FROM statement",
             bullet = "tick",
             bullet_col = "green")

  # preparing install statements for specific versions of CRAN packages.
  cran_versions_statement <- create_statement_cran_versions(pkg_deps)
  cat_bullet("Preparing install statements for specific versions of CRAN packages",
             bullet = "tick",
             bullet_col = "green")
  
  # preparing install statement for the package itself.
  install_main_package <- create_statement_main_package(paths$folder_source_packages,
                                                        paths$pkgname_pkgvrs)
  cat_bullet("Preparing install statement for the package itself",
             bullet = "tick",
             bullet_col = "green")

  # combine components to body for Dockerfile.
  Dockerfile_body <- c(FROM_statement,
                       cran_versions_statement,
                       install_main_package)

  # write contents to Dockerfile.
  writeLines(Dockerfile_body, con = Dockerfile)
  cat_bullet("Writing lines to Dockerfile",
             bullet = "tick",
             bullet_col = "green")

  # close connection to Dockerfile.
  close(Dockerfile)
  cat_bullet("Closing Dockerfile",
             bullet = "tick",
             bullet_col = "green")

  # print Dockerfile.
  if (print_dockerfile) {
    cat_bullet("Printing Contents of Dockerfile: ", blue(path_Dockerfile), "\n",
               bullet = "em_dash",
               bullet_col = "gray")
    print_file(paths$path_Dockerfile)
  }
  
  # texts for user assistance.
  cat(silver("- in R:\n"))
  cat(silver("=> to inspect Dockerfile run:\n"))
  cat(cyan(paste0("dockr::print_file(\"", paths$path_Dockerfile, "\")")), "\n")
  cat(silver("- in Shell:\n"))
  cat(silver("=> to build Docker image run:\n"))
  cat(cyan(paste0("cd ", paths$folder_docker)), "\n")
  cat(cyan(paste0("docker build -t ", paths$pkgname_pkgvrs, " .")), "\n")
  
  # return invisibly.
  invisible(paths)

}
