library(tsDyn)
data(zeroyld)
set.seed(42)
tv <- TVAR(zeroyld, lag=2, nthresh=1, thDelay=1, trim=0.1, mTh=1, plot=FALSE)
g <- GIRF(tv, c(0,1), horizon = 10, R = 2, H = 2)

test_that("Printing, summary and plot smoke tests", {
  expect_error(print(g), NA)
  expect_error(View(g), NA)
  expect_error(summary(g), NA)
  expect_error(plot(g), NA)
})

test_that("tidier for GIRF", {
  expect_named(tidy(g), c("horizon", "variable", "response"))
  expect_s3_class(g, "tibble")
})
