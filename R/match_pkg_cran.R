#' Match Packages with CRAN
#'
#' Match specific package versions with CRAN.
#'
#' @param pkgs_df \code{data.frame} with names of R packages "pkg" and their
#' corresponding version numbers "vrs".
#' @inheritParams prepare_docker_image
#' 
#' @importFrom curl has_internet
#' 
#' @return \code{data.frame} with package names (and versions) of dependency
#' packages matched with CRAN repos.
#'
#' @importFrom utils available.packages contrib.url
match_pkg_cran <- function(pkgs_df,
                           verbose = TRUE) {

  
  # handle case when there are no dependencies.
  if (is.null(pkgs_df)) {
    return(NULL)
  }

  # check if there is connection to the internet.
  if (!has_internet()) {
    stop("No connection to the internet. Please establish connection.")
  }
  
  # what package versions are available on CRAN presently?
  ap <- available.packages()
  ap <- as.data.frame(ap)
  # subset only relevant columns.
  ap <- ap[, c("Package", "Version"), drop = FALSE]
  ap$source <- "present"

  # match with desired packages.
  match_ap <- merge(x = pkgs_df, y = ap,
                    by.x = c("pkg", "vrs"),
                    by.y = c("Package", "Version"))

  # match any unmatched dependencies with archived R package versions.
  no_match <- merge(pkgs_df, match_ap, all.x = TRUE)
  no_match <- no_match[is.na(no_match$source), c("pkg", "vrs"), drop = FALSE]
  match_archive <- match_pkg_archive(no_match)

  # bind results.
  matches <- rbind(match_ap, match_archive)

  # print service information.
  if (verbose) {
    cat_bullet("Matching dependencies with CRAN packages",
               bullet = "tick",
               bullet_col = "green")
  }

  # return matches.
  matches

}

#' Match Archived Versions of CRAN Packages
#' 
#' Searches for a specific _archived_ version of an R package dependency
#' on CRAN.
#' 
#' @inheritParams match_pkg_cran
#'
#' @return \code{data.frame} with package names (and versions) of dependency
#' packages matched with CRAN repos.
match_pkg_archive <- function(pkgs_df) {

  # apply helper function to all packages, that checks if a specific archived
  # version of a package exists.
  match_archive <- suppressWarnings(
    mapply(match_pkg_archive_helper,
           pkg = pkgs_df$pkg,
           vrs = pkgs_df$vrs,
           USE.NAMES = FALSE,
           SIMPLIFY = FALSE)
  )

  # simplify to logical vector.
  match_lgl <- as.logical(match_archive)

  # handle case, when there are no matches.
  if (!any(match_lgl)) {
    return(NULL)
  }

  # subset packages with matches.
  pkgs_df <- pkgs_df[match_lgl, , drop = FALSE]
  pkgs_df$source <- "archive"

  pkgs_df

}

# checks if a specific archived version of a package exists.
match_pkg_archive_helper <- function(pkg, vrs) {

  # construct exact url to look for.
  url_archive <- paste0("https://cran.r-project.org/src/contrib/Archive/",
                        pkg, "/",
                        pkg, "_", vrs, ".tar.gz")

  # try to establish connection to file (/check if file exists).
  tryCatch({
    con <- gzcon(url(url_archive, "rb"))
    on.exit(close(con))
    TRUE
  },
  error = function(e) {FALSE})

}
