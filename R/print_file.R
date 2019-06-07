#' @export
print_file <- function(path) {
  # read text from file.
  query <- readChar(path, file.info(path)$size)
  # print text to console.
  cat(query)
}
