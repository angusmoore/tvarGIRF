[![Travis-CI Build Status](https://travis-ci.org/angusmoore/tvarGIRF.svg?branch=master)](https://travis-ci.org/angusmoore/tvarGIRF)
[![Coverage Status](https://coveralls.io/repos/github/angusmoore/tvarGIRF/badge.svg?branch=master)](https://coveralls.io/github/angusmoore/tvarGIRF?branch=master)

# tvarGIRF
`tvarGIRF` is an `R` package that calculates generalised impulse response functions to reduced form shocks for threshold vector autoregressions estimated using the `tsDyn` package.

## Installation

Install the package using the R `devtools` package:
```
library(devtools)
install_github("angusmoore/tvarGIRF")
```

## Usage
The library extends the R `tsDyn` package. The following example illustrates how to create a simple GIRF for a threshold VAR using the `zeroyld` dataset provided with the `tsDyn` package.

`GIRF` is given a reduced form shock - in the example below a shock to only the second variable `c(0,1)`. If you want to use orthoganlised shocks, you should calculate the orthogonalisation yourself and supply the reduced form shock that corresponds to your chosen structural shock. It is up to you to identify shocks; `tvarGIRF` won't do it for you.

```
library(tsDyn)
library(tvarGIRF)

# Estimate an example TVAR using the zeroyld dataset included in the tsDyn package
data(zeroyld)
exampleTVAR <- TVAR(zeroyld, lag=2, nthresh=1, thDelay=1, mTh=1, plot=FALSE)

# Calculate GIRFs for a reduced form shock to the second variable (long.run)
girfs <- GIRF(exampleTVAR, c(0,1))
```

The result contains the generalised impulse responses for each variable in the TVAR to the supplied shock. (NB: Since we have not identified shocks, these GIRFs are not very meaningful; this example is designed only to illustrate how to use the library.)

# Package documentation

Documentation for this package can be found [here](https://angusmoore.github.io/tvarGIRF/).
