context("combine_deps()")

# simulate CRAN deps.
deps_cran <- structure(list(pkg = c("p1", "p2", "p3"), 
                            vrs = c("1.0", "0.8", "0.9"),
                            source = c("present", "present", "archive")),
                       row.names = c(1L, 2L, 5L), class = "data.frame")

# simulate local deps (no overlap).
deps_local <- structure(list(pkg = "p4", 
                             vrs = "1.0", 
                             source = "~/"), 
                        row.names = 1L, class = "data.frame")

# simulate local deps (overlap).
deps_local_overlap <- data.frame(
  pkg = c("p2", "p4"),
  vrs = c("0.8", "1.0"),
  source = rep("local",  2),
  stringsAsFactors = FALSE
)

# simulate deps.
pkg_deps <- data.frame(
  pkg = paste0("p", 1:4),
  vrs = c("1.0", "0.8", "0.9", "1.0"),
  stringsAsFactors = FALSE
)

test_that("expected output", {
  
  # NULL output when no dependencies.
  expect_null(
    combine_deps(pkg_deps = NULL,
                 deps_cran = NULL,
                 deps_local = NULL))
  
  # expected output type - no overlap.
  res <- combine_deps(pkg_deps = pkg_deps,
                      deps_cran = deps_cran,
                      deps_local = deps_local)
  expect_is(res, "list")
  expect_identical(deps_cran, res$deps_cran)
  expect_identical(deps_local, res$deps_local)
  
  # error, if dependency is missing.
  expect_error(combine_deps(pkg_deps = pkg_deps,
                            deps_cran = deps_cran[1:2, ],
                            deps_local = deps_local))
  
  # expected output, if there is overlap, cran prioritized.
  res_cran <- combine_deps(pkg_deps = pkg_deps,
                            deps_cran = deps_cran,
                            deps_local = deps_local_overlap, prioritize_cran = TRUE)
  expect_equal(nrow(res_cran$deps_cran), nrow(deps_cran))
  expect_true(nrow(res_cran$deps_local) < nrow(deps_local_overlap))
  
  # expected output, if there is overlap, local packages prioritized.
  res_local <- combine_deps(pkg_deps = pkg_deps,
                           deps_cran = deps_cran,
                           deps_local = deps_local_overlap, prioritize_cran = FALSE)
  expect_equal(nrow(res_local$deps_local), nrow(deps_local_overlap))
  expect_true(nrow(res_local$deps_cran) < nrow(deps_cran))
  
})
