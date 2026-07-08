# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
# * https://testthat.r-lib.org/articles/special-files.html

library(testthat)

# Derive the package root from this file's own location, not from the working
# directory, which varies across devtools::test(), direct Rscript invocation,
# and R CMD check (where cwd is a temp .Rcheck/tests/ directory). R sets
# sys.frames()[[1]]$ofile to the path of the file currently being sourced,
# so dirname() twice walks up from tests/testthat.R to the package root.
pkg_root <- tryCatch(
  normalizePath(file.path(dirname(sys.frames()[[1]]$ofile), ".."), mustWork = FALSE),
  error = function(e) getwd()
)

# Only call load_all() when package source is present at the inferred root.
# During R CMD check the package is already installed into the check library,
# so DESCRIPTION will not exist one level above the .Rcheck/tests/ directory
# and we fall back to library() instead.
if (file.exists(file.path(pkg_root, "DESCRIPTION"))) {
  devtools::load_all(pkg_root)
} else {
  library(cori.data.fcc)
}

test_check("cori.data.fcc")
