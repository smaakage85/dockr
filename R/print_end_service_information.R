#' Print Service Information
#'
#' Prints service information, when files for Docker image have been created.
#'
#' @param path_Dockerfile \code{character} path for Dockerfile.
#' @param dir_image \code{character} path for files for Docker image.
#' @param pkgname_pkgvrs \code{character} package name concatenated with
#' package version number.
#'
#' @return returns invisibly.
print_end_service_information <- function(path_Dockerfile,
                                          dir_image,
                                          pkgname_pkgvrs) {

  # R stuff
  cat(silver("- in", blue("R"), silver(":"), "\n"))
  cat(silver("=> to inspect Dockerfile run:\n"))
  cat(cyan(paste0("dockr::print_file(\"", path_Dockerfile, "\")")), "\n")
  cat(silver("=> to edit Dockerfile run:\n"))
  cat(cyan(paste0("dockr::write_lines_to_file([lines], \"", path_Dockerfile, "\")")), "\n")

  # Shell stuff
  cat(silver("- in", yellow("Shell"), silver(":"), "\n"))
  cat(silver("=> to build Docker image run:\n"))
  cat(cyan(paste0("cd ", dir_image)), "\n")
  if (Sys.info()['sysname'] == "Linux") {
    cat(cyan(paste0("sudo docker build -t ", pkgname_pkgvrs, " .")), "\n")
  } else {
    cat(cyan(paste0("docker build -t ", pkgname_pkgvrs, " .")), "\n")
  }

  # return invisibly.
  invisible(NULL)

}

