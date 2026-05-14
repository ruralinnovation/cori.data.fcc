test_that("get_nbm_release return a data frame", {
  skip_on_cran()
  skip_on_ci()
  expect_equal(isTRUE(is.data.frame(get_nbm_available())), TRUE)
})
