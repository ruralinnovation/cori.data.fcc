test_that("FRN should be 10-digit string", {
  expect_error(get_frn_nbm_bl("bob"))
})

# could change in different release
test_that("Check nrow on skymesh", {
  expect_equal(nrow(get_frn_nbm_bl("0027136753")), 3L)
})

