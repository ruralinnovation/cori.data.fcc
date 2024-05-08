# test if check_frn return a row when called on one frn

test_that("check_frn return one row", {
  expect_equal(nrow(check_frn(8181448)), 1)
})
