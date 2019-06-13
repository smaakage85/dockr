check_permissions_dir <- function(dir,
                                  existence = TRUE,
                                  execute = TRUE,
                                  write = TRUE,
                                  read = TRUE) {

  # check input.
  if (!is.character(dir)) {
    stop("'dir' must be a character.")
  }
  if (length(dir) != 1) {
    stop("'dir' must have length 1.")
  }

  # check directory for existence.
  if (existence && file.access(dir, mode = 0) == -1) {
    stop(directory, " does not exist.")
  }

  # check directory for read permissions.
  if (execute && file.access(dir, mode = 1) == -1) {
    stop("No execute permissions for directory: ", directory)
  }

  # check directory for read permissions.
  if (read && file.access(dir, mode = 4) == -1) {
    stop("No read permissions for directory: ", directory)
  }

  # check directory for write permissions.
  if (write && file.access(dir, mode = 2) == -1) {
    stop("No write permissions for directory: ", directory)
  }

  TRUE

}
