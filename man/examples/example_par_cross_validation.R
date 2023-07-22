\dontrun{
  df <- data.frame(
    ds = seq.Date(as.Date('2022-01-01'), as.Date('2022-12-31'), 'day'),
    y = pi*cos(1:365)+rnorm(365))
  m <- prophet(df)
  cv <- par_cross_validation(
    model = m,
    horizon = 30,
    units = 'days',
    n.jobs = 2
  )
  print(cv)
}
