write_dockerfile <- function() {
  
  # prep docker folders and files.
  docker_paths <- prep_docker()
  Dockerfile_path <- docker_paths$Dockerfile_path
  
  # open connection to Dockerfile.
  Dockerfile <- file(Dockerfile_path)
  
  # write Dockerfile.
  cat_bullet("Writing Dockerfile...", 
             bullet = "bullet", 
             bullet_col = "gray")
  
  # write FROM statement.
  FROM_statement <- c("# load rocker r-base image", 
                      set_rocker_image(), 
                      "")
  writeLines(FROM_statement, Dockerfile)
  cat_bullet("Writing FROM statement to Dockerfile", 
             bullet = "tick", 
             bullet_col = "green")
  
  cat_bullet("Finished writing Dockerfile.", 
             bullet = "bullet", 
             bullet_col = "gray")
  
  # close connection to Dockerfile.
  close(Dockerfile)
  
  # return invisibly.
  invisible(NULL)
    
} 