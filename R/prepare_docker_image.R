#' Prepare Docker Image
#'
#' Prepares a Docker image for your R package by (1) identifying its R
#' dependency packages, (2) looking up, what versions of these packages that
#' are presently loaded or, subsidiarily, installed, (3) linking these specific
#' dependencies to the right repositories and finally (4) creating all of the
#' necessary files the Docker image - including a Dockerfile. As side effects
#' the package is built, installed and loaded.
#'
#' @param verbose \code{logical} should messages be printed or not?
#' @param directory \code{character} directory where all files for the Docker
#' image are saved, and from where the Docker image can be build.
#' @param print_dockerfile \code{logical} should the resulting Dockerfile be
#' printed? 
#' @param r_version \code{character} which version of base R to include in the 
#' Docker image, e.g. '3.6.0'. Defaults to NULL, which implies that the active 
#' version of R will apply.
#' @param dir_src \code{character} directories with local source packages. Put
#' directories in prioritized order. The first directory will have the highest
#' priority.
#' @param prioritize_cran \code{logical} should R dependency packages matched
#' with CRAN be prioritized over matches with local source packages?
#' @param overwrite \code{logical} if the directory for the files for the
#' Docker image already exists and is non-empty, should it be 
#' deleted/overwritten?
#'
#' @inheritParams gtools::getDependencies
#' @inheritParams devtools::build
#'
#' @return \code{list} relevant meta data of the files, that constitute
#' the Docker image. As a side effect all necessary files for the Docker image -
#' including the resulting Dockerfile - are saved in the desired directory.
#'
#' @export
#'
#' @importFrom crayon cyan silver yellow
prepare_docker_image <- function(pkg = ".",
                                 directory = NULL,
                                 print_dockerfile = FALSE,
                                 verbose = TRUE,
                                 r_version = NULL,
                                 dependencies = c("Depends", "Imports", "LinkingTo"),
                                 base = FALSE,
                                 recommended = FALSE,
                                 dir_src = NULL,
                                 prioritize_cran = TRUE,
                                 overwrite = TRUE) {

  # setup directory for Docker image.
  paths <- setup_dir_image(pkg = pkg,
                           directory = directory,
                           verbose = verbose,
                           overwrite = overwrite)

  # build, install and load package.
  build_and_install_package(pkg = pkg,
                            paths$dir_source_packages,
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
  pkg_deps <- identify_dependencies(pkg = pkg,
                                    dependencies = dependencies,
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
                                dir_src_docker = paths$dir_source_packages)

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
                  dir_src_docker = paths$dir_source_packages)

  # create copy to container statement.
  copy_to_container_statement <- c(
    "# copy source packages to container (*.tar.gz)",
    "COPY source_packages /source_packages",
    ""
    )

  # preparing install statements for local source packages.
  local_packages_statement <-
    create_statement_local_pkgs(deps$deps_local,
                                paths$dir_source_packages,
                                verbose)

  # preparing install statement for the package itself.
  install_main_package <- create_statement_main_package(paths$dir_source_packages,
                                                        paths$pkgname_pkgvrs,
                                                        verbose,
                                                        pkg)

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
  cat_bullet("Closing connection to Dockerfile",
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
    print_end_service_information(
      path_Dockerfile = paths$path_Dockerfile,
      dir_image = paths$dir_image,
      pkgname_pkgvrs = paths$pkgname_pkgvrs
    )
  }

  # return relevant information and meta data.
  list(paths = paths,
       deps_cran = deps$deps_cran,
       deps_local = deps$deps_local)

}
