#' Create Install Statements for Local Source Packages
#'
#' @param pkgs_df \code{data.frame} with names and version numbers of desired
#' packages.
#' @param dir_src_docker \code{character} directory of subfolder with
#' relevant source packages for a Docker image. Source packages will be copied
#' to this directory.
#' @inheritParams prepare_docker_image
#'
#' @return \code{character} install chunk for Dockerfile.
create_statement_local_pkgs <- function(pkgs_df,
                                        dir_src_docker = "/home/w19799@CCTA.DK/projects/dockr_0.8.0/source_packages/",
                                        verbose = TRUE) {

  # handle case, when no local dependencies are required.
  if (is.null(pkgs_df)) {
    return(NULL)
  }

  # create install statements.
  statements <- mapply(
    FUN = function(pkg, vrs) {

      # create source package file name.
      fn <- paste0(pkg, "_", vrs, ".tar.gz")

      # create install statements.
      statement <- paste0("RUN R -e 'install.packages(pkgs = \"", fn, "\", repos = NULL)'")

    },
    pkg = pkgs_df$pkg, vrs = pkgs_df$vrs, SIMPLIFY = FALSE, USE.NAMES = FALSE)

  # convert to one character vector.
  statements <- do.call(c, statements)

  # combine into one statement.
  statements <- c("# install local source packages",
    statements,
    "")
  
  # print service information.
  if (verbose) {
    cat_bullet("Preparing install statements for local source packages",
               bullet = "tick",
               bullet_col = "green") 
  }
  
  statements
  

}
