# test if check_frn return a row when called on one frn

test_that("check_frn return one row", {
  expect_equal(nrow(check_frn(8181448)), 1L)
})

# test if check frn retirhn multiple rows
# when called with more than one frn number

test_that("check_frn return two rows with c()", {
  expect_equal(nrow(check_frn(c(8590846, 0021352968))), 2L)
})

# test if it works with an object
test_that("check_frn return two row with object", {
  frn_test <- c(8590846, 0021352968)
  expect_equal(nrow(check_frn(frn_test)), 2L)
})