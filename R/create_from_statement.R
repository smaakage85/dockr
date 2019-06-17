#' Create From Statement for Dockerfile
#'
#' Creates FROM statement for Dockerfile and sets it up with a relevant
#' `rocker` image as a starting point.
#'
#' @inheritParams prepare_docker_image
#'
#' @return \code{character} FROM statement for Dockerfile.
create_from_statement <- function(r_version = NULL, verbose = FALSE) {

  # set rocker image with relevant version of R and create FROM statement.
  FROM_statement <- c("# load rocker base-R image",
                      set_rocker_image(r_version),
                      "")

  # print service information if desired.
  if (verbose) {
    cat_bullet("Preparing FROM statement",
               bullet = "tick",
               bullet_col = "green")
  }

  # return FROM statement.
  FROM_statement

}
