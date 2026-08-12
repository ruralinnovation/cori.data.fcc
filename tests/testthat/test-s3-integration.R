# Manual integration tests for the S3/DuckDB credential-vending path.
# Run interactively (these are skipped in CI and non-interactive sessions).
# They only check connectivity/auth (data frame, nonzero rows), not exact
# row counts, which are covered separately in the function-specific tests.

test_that("get_f477 reads from S3 via connect_to_s3()", {
  skip_if(!interactive(), "manual S3 integration test")
  result <- get_f477("AS")
  expect_true(is.data.frame(result))
  expect_gt(nrow(result), 0)
})

test_that("get_frn_nbm_bl reads from S3 via connect_to_s3()", {
  skip_if(!interactive(), "manual S3 integration test")
  result <- get_frn_nbm_bl("0027136753")
  expect_true(is.data.frame(result))
  expect_gt(nrow(result), 0)
})

test_that("get_nbm_bl reads from S3 via sync_s3_to_local()", {
  skip_if(!interactive(), "manual S3 integration test")
  result <- get_nbm_bl("47051")
  expect_true(is.data.frame(result))
  expect_gt(nrow(result), 0)
})

test_that("get_nbm_county reads from S3 via sync_s3_to_local()", {
  skip_if(!interactive(), "manual S3 integration test")
  result <- get_nbm_county("47051")
  expect_true(is.data.frame(result))
  expect_gt(nrow(result), 0)
})

test_that("get_nbm_county_raw reads from S3 via sync_s3_to_local()", {
  skip_if(!interactive(), "manual S3 integration test")
  result <- get_nbm_county_raw("48301")
  expect_true(is.data.frame(result))
  expect_gt(nrow(result), 0)
})
