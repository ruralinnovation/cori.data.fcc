test_that("FRN should be 10-digit string", {
  expect_error(get_frn_nbm_bl("bob"))
})

# could change in different release
# they had a 0/0 location
test_that("Check nrow on Cogent", {
  expect_equal(nrow(get_frn_nbm_bl("0019066034", release = "J24")), 1212)
})

# number of location went down in December 2024 release
test_that("Check nrow on Cogent - D24", {
  expect_equal(nrow(get_frn_nbm_bl("0019066034", release = "D24")), 1190)
})

# June 2025 release has different data
test_that("Check nrow on Cogent - J25 (latest)", {
  expect_equal(nrow(get_frn_nbm_bl("0019066034")), 828)
})

# could change in different release
# mostly sat except 3 locations ? so good weird test on data quality our logic
test_that("Check nrow on Skymesh from June 2024 release", {
  expect_equal(nrow(get_frn_nbm_bl("0027136753", release = "J24")), 3)
})

# number of location went up in December 2024 release
test_that("Check nrow on Skymesh - D24", {
  expect_equal(nrow(get_frn_nbm_bl("0027136753", release = "D24")), 11)
})

# June 2025 release has different data
test_that("Check nrow on Skymesh - J25 (latest)", {
  expect_equal(nrow(get_frn_nbm_bl("0027136753")), 12)
})
