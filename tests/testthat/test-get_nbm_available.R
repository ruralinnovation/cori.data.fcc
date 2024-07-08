test_that("get_nbm_release return a data frame", {
  expect_equal(isTRUE(is.data.frame(get_nbm_available())), TRUE)
})
