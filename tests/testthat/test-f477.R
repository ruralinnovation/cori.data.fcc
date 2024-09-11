test_that("Check AS", {
  expect_equal(nrow(get_f477("AS")), 12532)
})

test_that("Check AS and frn", {
  expect_equal(nrow(get_f477("as", frn = "0007435902")), 452)
})
