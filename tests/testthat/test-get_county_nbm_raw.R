# those can be slow so I am skeeping them
# adjust skippy accordinug to your needs

skippy <- TRUE

test_that("Check if nrow is correct", {
  skip_if(skippy, message = "skipping that test to speed up dev")
  expect_equal(nrow(get_county_nbm_raw("48301")), 943)
})

test_that("Check if nrow is correct", {
  skip_if(skippy, message = "skipping that test to speed up dev")
  expect_equal(nrow(get_county_nbm_raw("48301", frn = "0024535437")), 124)
})

test_that("Check if nrow is correct", {
  skip_if(skippy, message = "skipping that test to speed up dev")
  expect_equal(nrow(get_county_nbm_raw("48301", frn = "0024535437",
     release =  '2022-12-01')), 1)
})
