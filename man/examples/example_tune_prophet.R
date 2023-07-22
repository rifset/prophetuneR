\dontrun{
  df <- data.frame(
    ds = seq.Date(as.Date('2022-01-01'), as.Date('2022-12-31'), 'day'),
    y = pi*cos(1:365)+rnorm(365))
  tuning_result <- tune_prophet(
    df = df,
    horizon = 30,
    units = 'days',
    args.list = list(
      changepoint.prior.scale = c(0.001, 0.01, 0.1, 0.5),
      seasonality.prior.scale = c(0.01, 0.1, 1.0, 10.0)
    ),
    n.jobs = 2
  )
  print(tuning_result)
}

