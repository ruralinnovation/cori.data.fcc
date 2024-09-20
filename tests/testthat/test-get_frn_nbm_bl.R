test_that("FRN should be 10-digit string", {
  expect_error(get_frn_nbm_bl("bob"))
})

# could change in different release
# they had a 0/0 location 
test_that("Check nrow on Cogent", {
  expect_equal(nrow(get_frn_nbm_bl("0019066034")), 1232)
})

# could change in different release
# mostly sat except 3 locations ? so good weird test on data quality our logic 
test_that("Check nrow on Skymesh", {
  expect_equal(nrow(get_frn_nbm_bl("0027136753")), 3)
})