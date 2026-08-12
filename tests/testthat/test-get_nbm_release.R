test_that("get_nbm_release return a data frame", {
  skip_on_cran()
  skip_on_ci()
  skip_if_fcc_down()
  expect_equal(isTRUE(is.data.frame(get_nbm_release())), TRUE)
})