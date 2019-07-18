#' Print Contents of Text File
#'
#' Prints all contents of text file.
#'
#' @param path \code{character} file path of text file.
#'
#' @export
#' 
#' @examples
#' \donttest{
#' # create all files for a Docker image for the package in the current directory
#' img <- prepare_docker_image(pkg = ".")
#' 
#' # print resulting Dockerfile
#' print_file(img$paths$path_Dockerfile)
#' }
print_file <- function(path) {
  # read text from file.
  query <- readChar(path, file.info(path)$size)
  # print text to console.
  cat(query)
}
