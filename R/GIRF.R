#' Generalised impulse response function for a threshold VAR
#'
#' This function constructs GIRFs for an threshold VAR (from the tsDyn package) using variation of the method from Koop, Pesaran and Potter (1996).
#'
#' Specifically, the method bootstraps a history and then simulates the TVAR forward.
#' First it does so by imposing that the shock in the first period is equal to the supplied (reduced form) shock. Shocks in all periods subsequent are
#' bootstrapped from the distribution of reduced form shocks, _conditional on the current regime_. It repeats the simulation a second time, but with
#' a bootstrapped shock in place of the imposed shock (and then randomly bootstrapping shocks to simulate the TVAR as before). Since the TVAR is allowed
#' to endogenously change regime, the shock series will differ between the two simulations - both because each is randomly selected, and because the two
#' simulations will not necessarily have the same path for the regime. The difference between the two simulations is then saved as the response of
#' each of the variables in the TVAR to the shock.
#'
#' This process is repeated a number of times for each history, and for a number of histories and then averaged to construct the GIRF.
#'
#' Importantly, the supplied shock (and the shocks that are sampled) are reduced form. This means you are responsible for supplying a sensibly identifited
#' initial shock. But after that, by using reduced form shocks, there is no need to take a stand about identifying structural shocks for all of the monte
#' carlo simulation periods.
#'
#' Creates a (potentially multipanel) time series graph from a ts objecct. Supports bar and line (and combinations of).
#'
#' @param tvar An estimated tvar (from the tsDyn package) for which you wish to calculate a GIRF.
#' @param shock A column specifying which (reduced form) shock you wish to impose.
#' @param horizon (default 20) How many periods to simulate after the shock?
#' @param H (default 200) How many histories to sample.
#' @param R (default 500) How many times to replicate the forward simulation for each history.
#' @param restrict.to (integer) Do you want to restrict to a particular regime in the shock period (histories that lead to starting in any other regime will be ignored).
#'
#' @examples
#' \dontrun{
#' library(tsDyn)
#'   data(zeroyld)
#'   exampleTVAR <- TVAR(zeroyld, lag=2, nthresh=1, thDelay=1, mTh=1, plot=FALSE)
#'   girfs <- GIRF(exampleTVAR, c(0,1))
#' }
#'
#' @export
GIRF <- function(tvar, shock, horizon = 20, H = 200, R = 500, restrict.to = NA) {
  if (length(shock) != tvar$k) {
    stop(paste0("Your shock vector has the wrong length. Should be length ", tvar$k, " (the number of variables in your TVAR), but you passed in ", length(shock)))
  }
  data <- tvar$model[, 1:tvar$k]

  # Split the residuals by regime
  resdis <- list()
  for (r in 1:tvar$model.specific$nreg) {
    resdis[[r]] <- tvar$residuals[r == tvar$model.specific$regime[(1+tvar$lag):length(tvar$model.specific$regime)], ]
  }

  Y <- matrix(0, nrow = horizon, ncol = tvar$k)

  pb <- progress::progress_bar$new(total = H)

  for (h in 1:H) {
    pb$tick()

    # Find a history
    got.regime <- FALSE
    while (!got.regime) {
      start <- sample(tvar$t + 1,1)
      history <- data[start:(start+tvar$lag-1), ] # lower case omega t-1 in KPP notation
      r <- tvar$model.specific$regime[start + tvar$lag]
      r <- getregime(tvar, history[tvar$model.specific$thDelay, , drop = FALSE])
      if (is.na(restrict.to) || r == restrict.to) {
        got.regime <- TRUE
      }
    }

    # Now repeatedly simulate with and without shock
    Y_shock <- matrix(0, nrow = horizon, ncol = tvar$k)
    Y_base <- matrix(0, nrow = horizon, ncol = tvar$k)
    for (i in 1:R) {
      Y_shock <- Y_shock + GIRF.sim(tvar, history, horizon, shock, resdis)
      Y_base <- Y_base + GIRF.sim(tvar, history, horizon, NULL, resdis)
    }

    # Add the results from the history to the accumulator
    Y <- Y + (1/R)*(Y_shock - Y_base)
  }

  # Scale by number of histories
  Y <- (1/H)*Y
  colnames(Y) <- names(tvar$model)[1:tvar$k]
  Y <- tibble::as_tibble(Y)
  return(structure(list(
    responses = Y,
    H = H,
    R = R,
    shock = shock,
    tvar_name = deparse(substitute(tvar))
  ),
  class = "tvarGIRF"))
}

getregime <- function(tvar, input) {
  threshval <- 0
  for (i in 1:ncol(input)) {
    threshval <- threshval + input[1, i]*tvar$model.specific$transCombin[i]
  }
  r <- 1 + sum(threshval > tvar$model.specific$Thres)
  return(r)
}

GIRF.sim <- function(tvar, history, horizon, shock, resdis) {
  r <- getregime(tvar, history[nrow(history) - tvar$model.specific$thDelay + 1, , drop = FALSE])
  if(is.null(shock)) {
    # no imposed shock, so bootstrap one
    s <- sample(nrow(resdis[[r]]), size=1)
    shock <- resdis[[r]][s, ]
  }

  Y <- matrix(0, nrow = horizon, ncol = tvar$k)
  Y[1, ] <- sim.advance(tvar, history, shock)
  if (nrow(history) > 1) {
    history <- rbind(history[1:(nrow(history)-1), , drop = FALSE], Y[1, ])
  } else {
    history <- matrix(Y[1, ], nrow = 1, ncol = tvar$k)
  }
  shocklist <- shock
  for (t in 2:horizon) {
    r <- getregime(tvar, history[nrow(history) - tvar$model.specific$thDelay + 1, , drop = FALSE])
    # Sample a new shock
    s <- sample(nrow(resdis[[r]]), size=1)
    shock <- resdis[[r]][s, ]

    shocklist <- rbind(shocklist, shock)

    Y[t, ] <- sim.advance(tvar, history, shock)
    if (nrow(history) > 1) {
      history <- rbind(history[2:nrow(history), , drop = FALSE], Y[t, ])
    } else {
      history <- matrix(Y[t, ], nrow = 1, ncol = tvar$k)
    }
  }
  return(Y)
}

sim.advance <- function(tvar, history, v) {
  return(tsDyn::TVAR.sim(B = tvar$coeffmat,
                  Thresh = tvar$model.specific$Thresh,
                  nthres = tvar$model.specific$nthresh,
                  n = 1, lag = tvar$lag, include = tvar$include,
                  thDelay = tvar$model.specific$thDelay, mTh = which(tvar$model.specific$transCombin == 1),
                  starting = history, innov = matrix(data = v, nrow = 1, ncol = tvar$k)))
}
