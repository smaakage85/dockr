#' @importFrom crayon cyan silver
write_dockerfile <- function(print_dockerfile = FALSE) {

  # prep docker folders and files.
  paths <- prep_docker()

  # build and load package.
  folder_source_packages <- paths$folder_source_packages
  cat_bullet("Building, installing and loading package...",
             bullet = "em_dash",
             bullet_col = "gray")
  build_and_install_package(folder_source_packages,
                            paths$pkgname_pkgvrs)

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

  # combine components into body for Dockerfile.
  Dockerfile_body <- c(FROM_statement,
                       cran_versions_statement)

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
    print_file(path_Dockerfile)
  }
  
  # texts for user assistance.
  cat(silver("- in R:\n"))
  cat(silver("=> to inspect Dockerfile run:\n"))
  cat(cyan(paste0("print_file(\"", path_Dockerfile, "\")")), "\n")
  cat(silver("- in Shell:\n"))
  cat(silver("=> to build Docker image navigate to"), blue(paths$folder_docker), silver("and run:\n"))
  cat(cyan(paste0("docker build -t ", paths$pkgname_pkgvrs, " .")), "\n")
  
  # return invisibly.
  invisible(paths)

}
