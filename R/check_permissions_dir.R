#' Check Permissions for a Directory
#'
#' Checks if the user has one or more specific permissions for a given
#' directory.
#'
#' @param directory \code{character} directory to examine.
#' @param existence \code{logical} does directory exist?
#' @param execute \code{logical} does user have execute permissions for
#' directory?
#' @param write \code{logical} does user have write permissions for
#' directory?
#' @param read \code{logical} does user have read permissions for
#' directory?
#'
#' @return \code{logical} TRUE if user has all the specific permissions, 
#' otherwise FALSE.
check_permissions_dir <- function(directory,
                                  existence = TRUE,
                                  execute = TRUE,
                                  write = TRUE,
                                  read = TRUE) {

  # check input.
  if (!is.character(directory)) {
    stop("'directory' must be a character.")
  }
  if (length(directory) != 1) {
    stop("'directory' must have length 1.")
  }

  # check directory for existence.
  if (existence && file.access(directory, mode = 0) == -1) {
    stop(directory, " does not exist.")
  }

  # check directory for read permissions.
  if (execute && file.access(directory, mode = 1) == -1) {
    stop("No execute permissions for directory: ", directory)
  }

  # check directory for read permissions.
  if (read && file.access(directory, mode = 4) == -1) {
    stop("No read permissions for directory: ", directory)
  }

  # check directory for write permissions.
  if (write && file.access(directory, mode = 2) == -1) {
    stop("No write permissions for directory: ", directory)
  }

  TRUE

}
