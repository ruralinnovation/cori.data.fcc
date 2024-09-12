test_that("dictionnary is a dataframe", {
  expect_true(is.data.frame(fcc_dictionary(dataset = "f477")))
})
