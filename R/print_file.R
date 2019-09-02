#' Print Contents of Text File
#'
#' Prints all contents of text file.
#'
#' @param path \code{character} file path of text file.
#'
#' @export
#' 
#' @return prints contents of file as a side effect.
#' 
#' @examples
#' # create empty file.
#' fp <- file.path(tempdir(), "tester")
#' file.create(fp)
#' 
#' # append lines to Dockerfile.
#' write_lines_to_file("# no nonsense", filepath = fp)
#' 
#' print_file(fp)
print_file <- function(path) {
  # read text from file.
  query <- readChar(path, file.info(path)$size)
  # print text to console.
  cat(query)
}
