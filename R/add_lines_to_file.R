#' Write Lines to File
#'
#' @param lines \code{character} lines that will be written to file.
#' @param filepath \code{character} filepath of file to write lines to.
#' @param prepend \code{logical} should the new lines be prepended to
#' the existing text? Defaults to FALSE, which implies that the new lines will
#' be appended.
#' @param print_file \code{logical} should the contents of the file be printed
#' after editing? Defaults to TRUE.
#'
#' @return invisible return.
#'
#' @export
write_lines_to_file <- function(lines,
                              filepath = "",
                              prepend = FALSE,
                              print_file = TRUE) {

  # validate inputs.
  if (!is.character(lines)) {
    stop("'lines' must be a character vector.")
  }

  if (!length(lines) > 0) {
    stop("'lines' must have a positive length.")
  }


  if (prepend) {
    # read existing contents of file.
    text <- readChar(filepath, file.info(filepath)$size)
    # write lines plus existing contents to file.
    write(c(lines, text),
          filepath,
          append = FALSE,
          sep = "\n")
  } else {
    # append new lines to file.
    write(lines,
          filepath,
          append = TRUE,
          sep = "\n")
  }

  # print resulting file.
  if (print_file) {
    print_file(filepath)
  }

  # return invisibly.
  invisible(NULL)

}
