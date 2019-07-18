
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dockr <img src="man/figures/dockr.png" align="right" height=140/>

[![Travis-CI Build
Status](https://travis-ci.org/smaakage85/dockr.svg?branch=master)](https://travis-ci.org/smaakage85/dockr)
[![CRAN\_Release\_Badge](http://www.r-pkg.org/badges/version-ago/dockr)](https://CRAN.R-project.org/package=dockr)
[![CRAN\_Download\_Badge](http://cranlogs.r-pkg.org/badges/dockr)](https://CRAN.R-project.org/package=dockr)

`dockr` is a small toolkit to build a lightweight Docker base R
container image for your R package, in which the package itself is
available. The Docker image seeks to mirror your R session as close as
possible with respect to R specific dependencies. Both dependencies on
CRAN R packages as well as local non-CRAN R packages will be included in
the Docker container image.

## Installation

Install the development version of `dockr` with:

``` r
remotes::install_github("smaakage85/dockr")
```

Or install the version released on CRAN:

``` r
install.packages("dockr")
```

## Workflow

In order to create the files, that will constitute the Docker image,
simply invoke the `prepare_docker_image()` function and point to the
folder with your package.

The workflow of `prepare_docker_image()` is summarized below:

1.  Build and install the package on your system
2.  Identify R package dependencies of the package
3.  Detect the version numbers of the loaded and installed versions of
    these packages on your system
4.  Link the individual packages to the right repositories (either CRAN
    or local repos)
5.  Write Dockerfile and create all other files needed to build the
    Docker image

Now, I will let `dockr` do its magic and create the files for a Docker
base R container image, in which `dockr` is installed together with all
of the R package dependencies, `dockr` needs to run.

Beware that the files for the Docker image are created as side-effects
of the function call.

``` r
library(dockr)
image_dockr <- prepare_docker_image(".")
#> v Creating folder for files for Docker image: C:/Users/Lars/Documents/dockr_0.8.1
#> v Creating folder for source packages: C:/Users/Lars/Documents/dockr_0.8.1/source_packages
#> v Creating empty Dockerfile: C:/Users/Lars/Documents/dockr_0.8.1/Dockerfile
#> --- Building, installing and loading package...
#> Writing NAMESPACE
#> Writing NAMESPACE
#> --- Writing Dockerfile...
#> v Preparing FROM statement
#> v Identifying and mirroring R package dependencies
#> v Matching dependencies with CRAN packages
#> v Matching dependencies with local source packages
#> v Preparing install statements for specific versions of CRAN packages
#> v Preparing install statement for the package itself
#> v Writing lines to Dockerfile
#> v Closing connection to Dockerfile
#> - in R : 
#> => to inspect Dockerfile run:
#> dockr::print_file("C:/Users/Lars/Documents/dockr_0.8.1/Dockerfile") 
#> => to edit Dockerfile run:
#> dockr::write_lines_to_file([lines], "C:/Users/Lars/Documents/dockr_0.8.1/Dockerfile") 
#> - in Shell : 
#> => to build Docker image run:
#> cd C:/Users/Lars/Documents/dockr_0.8.1 
#> docker build -t dockr_0.8.1 .
```

Great, all necessary files for the Docker image have been created, and
you can build the Docker image right away by following the instructions.
It is as easy as that\! Yeah\!

## What about non-R dependencies?

`dockr` does *not* deal with non-R dependencies at this point. In case
that, for instance, your package has any Linux specific dependencies,
you will have to install them yourself in the Docker container image.

## Contact

I hope, that you will find `dockr` useful.

Please direct any questions and feedbacks to
[me](mailto:lars_kjeldgaard@hotmail.com)\!

If you want to contribute, open a
[PR](https://github.com/smaakage85/dockr/pulls).

If you encounter a bug or want to suggest an enhancement, please [open
an issue](https://github.com/smaakage85/dockr/issues).

Best, smaakagen
