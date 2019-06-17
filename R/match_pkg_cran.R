#' Match Packages with CRAN
#'
#' Match specific package versions with CRAN.
#'
#' @param pkgs_df \code{data.frame}
#' @inheritParams prepare_docker_image
#'
#' @importFrom utils available.packages
match_pkg_cran <- function(pkgs_df,
                           verbose = TRUE) {

  # handle case when there are no dependencies.
  if (is.null(pkgs_df)) {
    return(NULL)
  }

  # what package versions are available on CRAN presently?
  ap <- available.packages()
  ap <- as.data.frame(ap)
  ap <- ap[, c("Package", "Version")]
  ap$source <- "present"

  # match with desired packages.
  match_ap <- merge(x = pkgs_df, y = ap,
                    by.x = c("pkg", "vrs"),
                    by.y = c("Package", "Version"))

  # match with archived versions.
  no_match <- merge(pkgs_df, match_ap, all.x = TRUE)
  no_match <- no_match[is.na(no_match$source), c("pkg", "vrs")]
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

match_pkg_archive <- function(pkgs_df) {

  # apply helper function to all packages.
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
  pkgs_df <- pkgs_df[match_lgl, ]
  pkgs_df$source <- "archive"

  pkgs_df

}

match_pkg_archive_helper <- function(pkg, vrs) {

  # construct exact url to look for.
  url_archive <- paste0("https://cran.r-project.org/src/contrib/Archive/",
                        pkg, "/",
                        pkg, "_", vrs, ".tar.gz")


  # ! HANDLE VERSION NUMBER x.x-3 etc.

  # try to establish connection to file (/check if file exists).
  tryCatch({
    con <- gzcon(url(url_archive, "rb"))
    on.exit(close(con))
    TRUE
  },
  error = function(e) {FALSE})

}
