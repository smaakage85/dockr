This is a resubmission.

I have fixed issues adressed by  CRAN. I have
- Removed redundant "R"s from title.
- More unit tests added.
- Force user to choose directory for writing/saving files.
- The package now uses packageDescription() in stead of installed.packages() to
look up versions of installed packages.

## R CMD check results
0 errors | 0 warnings | 0 notes

## Other tests passed
- Travis CI
- rhub::check_for_cran() (0 errors, 0 warnings)