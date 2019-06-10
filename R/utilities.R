#' Plot the GIRFs
#'
#' Creates a ggplot of your responses, with each response in its own panel
#'
#' @param x The result of a call to `GIRF`
#' @param y Not used
#' @param ... Additional arguments; not used
#'
#' @export
plot.tvarGIRF <- function(x, y, ...) {
  x <- tidy(x)
  ggplot2::ggplot(x, ggplot2::aes(horizon, response)) +
    ggplot2::geom_line() +
    ggplot2::facet_grid(cols = ggplot2::vars(variable))
}

#' Print the GIRFs
#'
#' @param x The result of a call to `GIRF`
#' @param ... Additional arguments; not used
#'
#' @export
print.tvarGIRF <- function(x, ...) {
  cat(paste0(crayon::silver("# GIRF of tvar ",
             x$tvar_name,
             "\n")))
  print(x$responses)
  invisible(x)
}

#' View GIRFs
#'
#' Invoke a spreadsheet-style data view on some estimates GIRFs
#'
#' @param x The result of a call to `GIRF`
#' @param title title for viewer window. Defaults to name of tvar if missing.
#'
#' @export
View.tvarGIRF <- function(x, title) {
  if (missing(title)) {
    title <- x$tvar_name
  }
  utils::View(x$responses, title)
}

#' Print a summary of some estimated GIRFs
#'
#' @param object The result of a call to `GIRF`
#' @param ... Additional arguments; not used
#'
#' @export
summary.tvarGIRF <- function(object, ...) {
  cat(paste0(
    "GIRF of tvar ",
    object$tvar_name,
    " (",
    ncol(object$responses),
    " variables)\n"
  ))
  cat(paste0("Calculated over ", object$H, " horizons (each history replicated ", object$R, " times)\n"))
  cat("\n")
  print(object$responses)
  invisible(object)
}

#' Convert GIRF responses to tidy form
#'
#' @param x GIRFs returned by a call to `GIRF`
#' @param ... Additional arguments to tidying method; not used
#'
#' @return A tibble in long form
#' @export
tidy.tvarGIRF <- function(x, ...) {
  x <- tibble::as_tibble(x$responses)
  x$horizon <- 1:nrow(x)
  tidyr::gather(x, variable, response, -horizon)
}
