#' Hyperparameter tuning for prophet
#'
#' Hyperparameter tuning for \link[prophet]{prophet} model via grid search algorithm
#' using parallelized cross-validation to shorten tuning time
#'
#' @param df Dataframe containing the history. Must have columns ds (date type) and y,
#' the time series. If growth is logistic, then df must also have a column cap that
#' specifies the capacity at each ds. If not provided, then the model object will be
#' instantiated but not fit; use fit.prophet(m, df) to fit the model.
#' @param horizon Integer size of the horizon.
#' @param units String unit of the horizon, e.g., "days", "secs".
#' @param args.list List of parameters values to be evaluated. Based on `prophet`
#'  official documentation, parameters that can be tuned including:
#'  `changepoint.prior.scale`, `seasonality.prior.scale`, `holidays.prior.scale`,
#'  `seasonality.mode`, and `changepoint.range`
#' @param ... Additional arguments, passed to \link[prophetuneR]{par_cross_validation}
#'
#'
#' @return A dataframe with the parameters and their performance metrics.
#'
#' @example man/examples/example_tune_prophet.R
#'
#' @export
tune_prophet <- function(df, horizon, units, args.list, ...) {
  available.args <- c('changepoint.prior.scale', 'seasonality.prior.scale',
                      'holidays.prior.scale', 'seasonality.mode',
                      'changepoint.range')
  if (!all(names(args.list) %in% available.args)) {
    stop(paste('parameters that can be tuned are:',
               paste(paste0('"', available.args, '"'), collapse = ', ')))
  }
  if (length(args.list) == 0) {
    stop('argument "args.list" cannot empty')
  }
  dots <- list(...)
  all_params <- expand.grid(args.list)
  tuning <- lapply(1:nrow(all_params), function(i) {
    arg <- c(list(df = df), dplyr::slice(all_params, i))
    m <- do.call(prophet, arg)
    cv.arg <- c(list(model = m, horizon = horizon, units = units), dots)
    cv <- do.call(par_cross_validation, cv.arg)
    pm <- dplyr::select(performance_metrics(cv, rolling_window = 1), -horizon)
    return(pm)
  })
  result <- cbind(all_params, do.call(rbind, tuning))
  return(result)
}
