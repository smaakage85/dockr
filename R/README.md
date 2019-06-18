
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- # dockr <img src="man/figures/logo.png" align="right" height=140/> -->
dockr
=====

[![Travis-CI Build Status](https://travis-ci.org/smaakage85/dockr.svg?branch=master)](https://travis-ci.org/smaakage85/dockr) [![CRAN\_Release\_Badge](http://www.r-pkg.org/badges/version-ago/dockr)](https://CRAN.R-project.org/package=dockr) [![CRAN\_Download\_Badge](http://cranlogs.r-pkg.org/badges/dockr)](https://CRAN.R-project.org/package=dockr)

`dockr` is a lightweight toolkit to validate new observations when computing their corresponding predictions with a predictive model.

With `dockr` the validation process consists of two steps:

1.  record relevant statistics and meta data of the variables in the original training data for the predictive model
2.  use these data to run a set of basic validation tests on the new set of observations.

Motivation
----------

There can be many data specific reasons, why you might not be confident in the predictions of a predictive model on new data.