test_that("dictionnary is a dataframe", {
  expect_true(is.data.frame(get_fcc_dictionary(dataset = "f477")))
})
