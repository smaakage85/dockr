#' Prepare Docker Image
#'
#' Prepares Docker image for the package by (1) looking up its dependencies,
#' (2) linking them to the right repositories and finally (3) creating all of
#' the necessary files for the image - including the Dockerfile.
#'
#' @param verbose \code{logical} should messages be printed or not?
#' @param directory \code{character} directory where the files for the Docker
#' image are put.
#' @param print_dockerfile \code{logical} should the resulting Dockerfile be
#' printed?
#' @param r_version \code{character} which version of R should the Docker image
#' run in, e.g. '3.6.0'. If set to NULL, the active version will apply.
#' @param dir_src \code{character} directories with local source packages. Put
#' directories in prioritized order. The first directory will have the highest
#' @param prioritize_cran \code{logical} should dependencies matched with
#' CRAN be prioritized over matches with local source packages.
#'
#' @inheritParams gtools::getDependencies
#'
#' @return \code{list} relevant meta data of the files, that constitute
#' the Docker image. As a side effect the files for the Docker image -
#' including the resulting Dockerfile - are saved in the desired directory.
#'
#' @export
#'
#' @importFrom crayon cyan silver
prepare_docker_image <- function(directory = NULL,
                                 print_dockerfile = FALSE,
                                 verbose = TRUE,
                                 r_version = NULL,
                                 dependencies = c("Depends", "Imports", "LinkingTo"),
                                 base = FALSE,
                                 recommended = FALSE,
                                 dir_src = NULL,
                                 prioritize_cran = TRUE) {

  # prep docker folders and files.
  paths <- setup_directory_for_docker(directory = directory,
                                      verbose = verbose)

  # build, install and load package.
  build_and_install_package(paths$folder_source_packages,
                            paths$pkgname_pkgvrs,
                            verbose)

  # open connection to Dockerfile.
  Dockerfile <- file(paths$path_Dockerfile)
  on.exit(close(Dockerfile))

  # write Dockerfile.
  if (verbose) {
    cat_bullet("Writing Dockerfile...",
               bullet = "em_dash",
               bullet_col = "gray")
  }

  # preparing FROM statement.
  FROM_statement <- create_from_statement(r_version, verbose)

  # identify package dependencies.
  pkg_deps <- identify_dependencies(dependencies = dependencies,
                                    base = base,
                                    recommended = recommended,
                                    verbose = verbose)

  # match with CRAN packages.
  deps_cran <- match_pkg_cran(pkg_deps,
                              verbose)

  # look in parent folder of package, if no directory has been provided.
  if (is.null(dir_src)) {
    dir_src <- dirname(pkg_path())
  }

  # match with local source packages.
  deps_local <- match_pkg_local(pkg_deps,
                                verbose = verbose,
                                dir_src = dir_src,
                                dir_src_docker = paths$folder_source_packages)

  # combine and consolidate dependencies.
  deps <- combine_deps(pkg_deps,
                       deps_cran,
                       deps_local,
                       prioritize_cran = FALSE)

  # preparing install statements for specific versions of CRAN packages.
  cran_versions_statement <- create_statement_cran_versions(deps$deps_cran,
                                                            verbose)

  # copy any relevant source packages.
  copy_local_pkgs(deps$deps_local,
                  verbose = verbose,
                  dir_src = dir_src,
                  dir_src_docker = paths$folder_source_packages)

  # create copy to container statement.
  copy_to_container_statement <- c(
    "# copy source_packages to container (*.tar.gz)",
    "COPY source_packages /source_packages",
    ""
    )

  # preparing install statements for local source packages.
  local_packages_statement <-
    create_statement_local_pkgs(deps$deps_local,
                                paths$folder_source_packages,
                                verbose)

  # preparing install statement for the package itself.
  install_main_package <- create_statement_main_package(paths$folder_source_packages,
                                                        paths$pkgname_pkgvrs,
                                                        verbose)

  # combine components to body for Dockerfile.
  Dockerfile_body <- c(FROM_statement,
                       cran_versions_statement,
                       copy_to_container_statement,
                       local_packages_statement,
                       install_main_package)

  # write contents to Dockerfile.
  writeLines(Dockerfile_body, con = Dockerfile)
  cat_bullet("Writing lines to Dockerfile",
             bullet = "tick",
             bullet_col = "green")

  # close connection to Dockerfile.
  cat_bullet("Closing Dockerfile",
             bullet = "tick",
             bullet_col = "green")

  # print Dockerfile.
  if (print_dockerfile) {
    cat_bullet("Printing Contents of Dockerfile: ", blue(paths$path_Dockerfile), "\n",
               bullet = "em_dash",
               bullet_col = "gray")
    print_file(paths$path_Dockerfile)
  }

  # texts for user assistance.
  if (verbose) {
    cat(silver("- in R:\n"))
    cat(silver("=> to inspect Dockerfile run:\n"))
    cat(cyan(paste0("dockr::print_file(\"", paths$path_Dockerfile, "\")")), "\n")
    cat(silver("=> to edit Dockerfile run:\n"))
    cat(cyan(paste0("dockr::write_lines_to_file([lines], \"", paths$path_Dockerfile, "\")")), "\n")
    cat(silver("- in Shell:\n"))
    cat(silver("=> to build Docker image run:\n"))
    cat(cyan(paste0("cd ", paths$folder_docker)), "\n")
    if (Sys.info()['sysname'] == "Linux") {
      cat(cyan(paste0("sudo docker build -t ", paths$pkgname_pkgvrs, " .")), "\n")
    } else {
      cat(cyan(paste0("docker build -t ", paths$pkgname_pkgvrs, " .")), "\n")
    }
  }

  # return invisibly.
  invisible(list(paths = paths,
                 deps_cran = deps$deps_cran,
                 deps_local = deps$deps_local))

}
