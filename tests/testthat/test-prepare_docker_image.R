context("prepare_docker_image")

# set options temporarily.
opts <- options()
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# get package directory.
package_dir <- system.file(package = "dockr")

# prepare docker image to temporary directory.
img <- prepare_docker_image(pkg = package_dir, dir_image = tempdir(), dir_install = "temp")

test_that("files created as expected", {

  expect_true(dir.exists(img$paths$dir_image))
  expect_true(file.exists(img$paths$path_Dockerfile))
  expect_true(dir.exists(img$paths$dir_source_packages))

  # Dockerfile is not empty.
  expect_true(file.info(img$paths$path_Dockerfile)$size > 0)

  # Source Package is created succesfully.
  expect_true(file.exists(file.path(img$paths$dir_source_packages,
                                    paste0(img$paths$pkgname_pkgvrs, ".tar.gz"))))

})

test_that("dependencies behave as expected", {

  expect_is(img$deps_cran, "data.frame")
  # positive number of dependencies to CRAN.
  expect_gt(nrow(img$deps_cran), 0)

  expect_null(img$deps_local)

})

test_that("correct handling of invalid (default) inputs", {

  # errors, when directories are not provided.
  expect_error(prepare_docker_image(dir_install = "temp"))
  expect_error(prepare_docker_image(dir_image = tempdir()))

})

# clean up and reset options.
options(opts)