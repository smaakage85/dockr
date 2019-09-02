This is a resubmission.

I have fixed issues adressed by CRAN. I have
- Changed examples for functions `write_lines_to_file()` and `print_file()` into
executable examples.
- I have set the example for `prepare_docker_image()` to `dontrun`, because the
function call takes more than five seconds to run. Please also note that the 
function is called succesfully in the tests (test-prepare_docker_image.R) with 
_exactly_ the same arguments.
- In comparison the function `install.packages()` from the `utils` package,
that install packages, also only has an example, that is not run. So I really
hope, that it is okay with you.

## R CMD check results
0 errors | 0 warnings | 0 notes

## Other tests passed
- Travis CI
- rhub::check_for_cran() (0 errors, 0 warnings)