find_pkgs_local <- function(pkg = "recorder", 
                            vrs = "0.8.1", 
                            dir_src = "/home/lars/recorder_0.8.1/source_packages/",
                            dir_src_docker = "/home/lars/dockr_0.8.0/source_packages/") {
  
  # check if dir exists.
  if (!dir.exists(dir_src)) {
    stop("Directory ", dir_src, " does not exist.")
  }
  
  # check for read permission (mode = 4).
  if (file.access(dir_src, mode = 4) == -1) {
    stop("Does not have read permission for: ", dir_src)
  }
  
  # list files in directory.  
  files <- list.files(dir_src)
  
  # is package among files?
  pkg_file <- paste0(pkg, "_", vrs, ".tar.gz")
  is_in_files <- pkg_file %in% files
  
  if (!is_in_files) {
    return(FALSE)
  }
  
  # move .tar.gz file to Docker source packages folder.
  file.copy(file.path(dir_src, pkg_file), dir_src_docker)
  
}