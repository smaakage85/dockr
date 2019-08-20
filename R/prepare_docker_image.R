#' Prepare Docker Image
#'
#' Prepares a Docker base R image for your R package by (1) identifying its R
#' dependency packages, (2) looking up, what versions of these packages that
#' are presently loaded or, subsidiarily, installed, (3) linking these specific
#' dependencies to the right repositories and finally (4) creating all of the
#' necessary files the Docker image - including a Dockerfile. As side effects
#' the package is built, installed and loaded.
#'
#' @param verbose \code{logical} should messages be printed or not?
#' @param dir_image \code{character} directory where to create folder for 
#' all files for the Docker image, and from where the Docker image can be build.
#' @param print_dockerfile \code{logical} should the resulting Dockerfile be
#' printed? 
#' @param r_version \code{character} which version of base R to include in the 
#' Docker image, e.g. '3.6.0'. Defaults to NULL, which implies that the active 
#' version of R will apply.
#' @param dir_src \code{character} directories with local source packages. 
#' Note, the source packages must have filenames like
#' (packageName)_(packageVersion).tar.gz, e.g. "recorder_0.8.2.tar.gz".
#' Put directories in prioritized order. The first directory will have the 
#' highest priority.
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
#' 
#' @examples
#' \donttest{
#' # create all files for a Docker image for the package in the current directory
#' img <- prepare_docker_image(pkg = ".")
#' 
#' # look up meta data for files for Docker image
#' img
#' }
prepare_docker_image <- function(pkg = ".",
                                 dir_image = NULL,
                                 print_dockerfile = FALSE,
                                 dir_install = "temp",
                                 verbose = TRUE,
                                 r_version = NULL,
                                 dependencies = c("Depends", "Imports", "LinkingTo"),
                                 base = FALSE,
                                 recommended = FALSE,
                                 dir_src = NULL,
                                 prioritize_cran = TRUE,
                                 overwrite = TRUE) {

  # validate inputs.
  if (!is.null(r_version)) {
    if (!is.character(r_version)) {
      stop("'r_version' must be character (or NULL).")
    }
    if (length(r_version) != 1) {
      stop("'r_version' must have length 1.")
    }
  }
  
  # directory for docker files must be provided by the user according to CRAN 
  # policies.
  if (is.null(dir_image)) {
    stop("Please choose location for files for docker image with the ",
         "'dir_image' argument.")
  } else  {
    if (!is.character(dir_image)) {
      stop("'dir_image' must be a filepath - and belong to the 'character'",
           "class.")
    }
    if (length(dir_image) != 1) {
      stop("'dir_image' must have a length 1.")
    }
  }
  
  if (!is.null(dir_src)) {
    if (!is.character(dir_src)) {
      stop("'dir_src' must be character (or NULL).")
    }
    if (length(dir_src) < 1) {
      stop("'dir_src' must have a length of minimum 1.")
    }
  }
  
  # setup directory for Docker image.
  paths <- setup_dir_image(pkg = pkg,
                           directory = dir_image ,
                           verbose = verbose,
                           overwrite = overwrite)

  # save library paths in order to restore on exit.
  lp <- .libPaths()
  
  # setup library paths.
  set_lib_paths(dir_install = dir_install)
  
  # build, install and load package.
  build_and_install_package(pkg = pkg,
                            paths$dir_source_packages,
                            paths$pkgname_pkgvrs,
                            verbose)

  # open connection to Dockerfile.
  Dockerfile <- file(paths$path_Dockerfile)
  
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
  # unlist items.
  pkg_deps_recursively <- pkg_deps$deps_recursively
  pkg_deps <- pkg_deps$deps_mirror
  
  # match with CRAN packages.
  deps_cran <- match_pkg_cran(pkg_deps, verbose)

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
                       prioritize_cran = prioritize_cran)

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
    "# copy source packages (*.tar.gz) to container",
    "COPY source_packages /source_packages",
    ""
    )

  # preparing install statements for local source packages.
  local_packages_statement <-
    create_statement_local_pkgs(deps$deps_local,
                                paths$dir_source_packages,
                                verbose,
                                pkg_deps_recursively)

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
  
  # clean up, reset lib paths.
  on.exit({close(Dockerfile); .libPaths(lp)})

  # return relevant information and meta data.
  list(paths = paths,
       deps_cran = deps$deps_cran,
       deps_local = deps$deps_local)

}
