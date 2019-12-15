#' Prepare Docker Image
#'
#' Prepares a Docker r-base image for your R package by (1) building and 
#' installing the package on your system, (2) identifying R package dependencies
#' of the package, (3) detecting the version numbers of the loaded and installed 
#' versions of these packages on your system, (4) linking the individual
#' packages to the right repositories (either CRAN or local repos) and (5) 
#' writing Dockerfile and creating all other files needed to build the 
#' Docker r-base image.
#'
#' @param verbose \code{logical} should messages be printed or not?
#' @param dir_image \code{character} directory where to create folder for 
#' all files for the Docker image, from where the Docker image can be build.
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
#' @param dir_install \code{character} where should the package be installed
#' on your system. Choose from `auto` (automatic detection), `temp` 
#' (temporary directory) or specify directory yourself.
#' @param ... optional arguments for `install.packages()`.
#'
#' @inheritParams gtools::getDependencies
#' @inheritParams devtools::build
#'
#' @return \code{list} relevant meta data of the files, that constitute
#' the Docker image. As a side effect all necessary files for the Docker image -
#' including the resulting Dockerfile - are saved in the desired directory.
#'
#' @importFrom crayon cyan silver yellow
#' 
#' @export
#' 
#' @examples
#' \donttest{
#' # retrieve package directory for the 'dockr' package.
#' package_dir <- system.file(package = "dockr")
#' # this concludes the preparations. 
#' 
#' # now for the real action.
#' 
#' # create all files for a Docker image for the package in the current directory.
#' img <- prepare_docker_image(pkg = package_dir, dir_image = tempdir(), dir_install = "temp")
#' 
#' # look up meta data for files for Docker image.
#' img
#' }
prepare_docker_image <- function(pkg = ".",
                                 dir_image = NULL,
                                 print_dockerfile = FALSE,
                                 dir_install = NULL,
                                 verbose = TRUE,
                                 r_version = NULL,
                                 dependencies = c("Depends", "Imports", "LinkingTo"),
                                 base = FALSE,
                                 recommended = FALSE,
                                 dir_src = NULL,
                                 prioritize_cran = TRUE,
                                 overwrite = TRUE,
                                 ...) {

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
      stop("'dir_src' must be a character (or NULL).")
    }
    if (length(dir_src) < 1) {
      stop("'dir_src' must have a length of minimum 1.")
    }
  }
  
  if (!is.null(pkg)) {
    if (!is.character(pkg)) {
      stop("'pkg' must be a character.")
    }
    if (length(pkg) != 1) {
      stop("'pkg' must have a length of 1.")
    }
    if (!dir.exists(pkg)) {
      stop("'pkg' must be a directory.")
    }
  }

  # setup directory for Docker image.
  paths <- setup_dir_image(pkg = pkg,
                           dir_image = dir_image ,
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
                            verbose,
                            ...)

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
