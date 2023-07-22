globalVariables(c(
  "ds", "y", "cap", "yhat", "yhat_lower", "yhat_upper", "size"))

generate_cutoffs <- utils::getFromNamespace('generate_cutoffs', 'prophet')
set_date <- utils::getFromNamespace('set_date', 'prophet')
single_cutoff_forecast <- utils::getFromNamespace('single_cutoff_forecast', 'prophet')

#' Parallel Cross-validation for prophet
#'
#' Parallelized version of \link[prophet]{cross_validation} from prophet forecasting tool
#'
#' @param model Fitted Prophet model.
#' @param horizon Integer size of the horizon.
#' @param units String unit of the horizon, e.g., "days", "secs".
#' @param period Integer amount of time between cutoff dates. Same units as
#'  horizon. If not provided, 0.5 * horizon is used.
#' @param initial Integer size of the first training period. If not provided,
#'  3 * horizon is used. Same units as horizon.
#' @param cutoffs Vector of cutoff dates to be used during
#'  cross-validation. If not provided works beginning from (end - horizon),
#'  works backwards making cutoffs with a spacing of period until initial is
#'  reached.
#' @param n.jobs **(New)** Number of cores to run in parallel, if `-1` all available
#'  cores are used (default is `-1`)
#'
#' @return A dataframe with the forecast, actual value, and cutoff date.
#'
#' @example man/examples/example_par_cross_validation.R
#'
#'
#' @export
#' @import prophet
#' @import parallel
par_cross_validation <- function(
    model, horizon, units, period = NULL, initial = NULL, cutoffs=NULL, n.jobs = -1L) {
  df <- model$history
  horizon.dt <- as.difftime(horizon, units = units)
  predict_columns <- c('ds', 'yhat')
  if (model$uncertainty.samples){
    predict_columns <- append(predict_columns, c('yhat_lower', 'yhat_upper'))
  }
  # Identify largest seasonality period
  period.max <- 0
  for (s in model$seasonalities) {
    period.max <- max(period.max, s$period)
  }
  seasonality.dt <- as.difftime(period.max, units = 'days')
  if (is.null(cutoffs)){

    # Set period
    if (is.null(period)) {
      period <- 0.5 * horizon
    }
    period.dt <- as.difftime(period, units = units)
    # Set initial
    if (is.null(initial)) {
      initial.dt <- max(
        as.difftime(3 * horizon, units = units),
        seasonality.dt
      )
    } else {
      initial.dt <- as.difftime(initial, units = units)
    }
    cutoffs <- generate_cutoffs(df, horizon.dt, initial.dt, period.dt)
  } else {
    cutoffs <- set_date(ds=cutoffs)
    # Validation
    if (min(cutoffs) <= min(df$ds)) {
      stop('Minimum cutoff value is not strictly greater than min date in history')
    }
    end_date_minus_horizon <- max(df$ds) - horizon.dt
    if (max(cutoffs) > end_date_minus_horizon) {
      stop('Maximum cutoff value is greater than end date minus horizon')
    }
    initial.dt <- cutoffs[1] - min(df$ds)
  }
  # Check if the initial window  (that is, the amount of time between the
  # start of the history and the first cutoff) is less than the
  # maximum seasonality period
  if (initial.dt < seasonality.dt) {
    warning(paste0('Seasonality has period of ', period.max, ' days which ',
                   'is larger than initial window. Consider increasing initial.'))
  }

  cl <- makeCluster(ifelse(n.jobs == -1L, detectCores(), n.jobs))
  clusterEvalQ(cl, {
    library(prophet)
  })
  predicts_list <- parLapply(cl, cutoffs, function(cutoff) {
    single_cutoff_forecast(df, model, cutoff, horizon.dt, predict_columns)
  })
  stopCluster(cl)
  predicts <- do.call(rbind, predicts_list)
  return(predicts)
}
