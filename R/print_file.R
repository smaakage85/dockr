#' Print Contents of Text File
#'
#' Prints all contents of text file.
#'
#' @param path \code{character} file path of text file.
#'
#' @export
print_file <- function(path) {
  # read text from file.
  query <- readChar(path, file.info(path)$size)
  # print text to console.
  cat(query)
}
