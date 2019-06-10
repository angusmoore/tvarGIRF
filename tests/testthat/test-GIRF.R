library(tsDyn)
data(zeroyld)
set.seed(42)

test_that("Known output tests", {
  tv <- TVAR(zeroyld, lag=2, nthresh=1, thDelay=1, trim=0.1, mTh=1, plot=FALSE)
  expect_known_hash(GIRF(tv, c(0,1), horizon = 10, R = 2, H = 2), "bb3f")

  tv <- TVAR(zeroyld, lag=2, nthresh=2, thDelay=1, trim=0.1, mTh=1, plot=FALSE)
  expect_known_hash(GIRF(tv, c(0,1), horizon = 10, R = 2, H = 2), "5937")
})


test_that("Errors for bad input", {
  tv <- TVAR(zeroyld, lag=2, nthresh=1, thDelay=1, trim=0.1, mTh=1, plot=FALSE)
  expect_error(GIRF(tv, 2, horizon = 10, R = 2, H = 2),
               "Your shock vector has the wrong length")
})
