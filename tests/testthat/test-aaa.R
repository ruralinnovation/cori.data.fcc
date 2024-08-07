test_that("the$user_agent should be string", {
  expect_type(the$user_agent, "character")
})

test_that("error if set_user_agent", {
  expect_error(set_user_agent(1))
})

test_that("seting user agent should change it", {
  set_user_agent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36")
  expect_equal(the$user_agent,
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36")
})