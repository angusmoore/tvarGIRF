library(tsDyn)
data(zeroyld)
tv <- TVAR(zeroyld, lag=2, nthresh=1, thDelay=1, trim=0.1, mTh=1, plot=FALSE)
g <- GIRF(tv, c(0,1), horizon = 10, R = 2, H = 2)

tv <- TVAR(zeroyld, lag=2, nthresh=2, thDelay=1, trim=0.1, mTh=1, plot=FALSE)
g <- GIRF(tv, c(0,1), horizon = 10, R = 2, H = 2)
