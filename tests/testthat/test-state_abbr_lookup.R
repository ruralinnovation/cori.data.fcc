test_that("state_abbr_lookup error when not scalar", {
  expect_error(state_abbr_lookup(c(1:3)))
})

test_that("state_abbr_lookup error when bob", {
  expect_error(state_abbr_lookup(bob))
})

test_that("state_abbr_lookup return OH if 39", {
  expect_identical(state_abbr_lookup("39"), "OH")
})

test_that("state_abbr_lookup return OH if 39", {
  expect_identical(state_abbr_lookup(39), "OH")
})

test_that("state_abbr_lookup return VT if VT", {
  expect_identical(state_abbr_lookup("VT"), "VT")
})
