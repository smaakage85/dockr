This is a resubmission.

I have fixed issues adressed by CRAN. I have
- 'build_and_install_package': allow optional arguments for install.packages
- 'set_rocker_image': use getRversion()
- removed repos-settings from example

## R CMD check results
0 errors | 0 warnings | 0 notes

## Other tests passed
- Travis CI
- rhub::check_for_cran() (0 errors, 0 warnings)