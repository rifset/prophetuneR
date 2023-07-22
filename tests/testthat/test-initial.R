test_that("default parallel", {
  expect_no_error({
    df <- data.frame(
      ds = seq.Date(as.Date('2022-01-01'), as.Date('2022-12-31'), 'day'),
      y = pi*cos(1:365)+rnorm(365)
    )
    suppressMessages({
      m <- prophet(df)
      par_cross_validation(
        model = m,
        horizon = 30,
        units = 'days',
        n.jobs = 2
      )
    })
  })
})

test_that("custom cores parallel", {
  expect_no_error({
    df <- data.frame(
      ds = seq.Date(as.Date('2022-01-01'), as.Date('2022-12-31'), 'day'),
      y = pi*cos(1:365)+rnorm(365)
    )
    suppressMessages({
      m <- prophet(df)
      par_cross_validation(
        model = m,
        horizon = 30,
        units = 'days',
        n.jobs = 2
      )
    })
  })
})

test_that("zero core parallel", {
  expect_error({
    df <- data.frame(
      ds = seq.Date(as.Date('2022-01-01'), as.Date('2022-12-31'), 'day'),
      y = pi*cos(1:365)+rnorm(365)
    )
    suppressMessages({
      m <- prophet(df)
      par_cross_validation(
        model = m,
        horizon = 30,
        units = 'days',
        n.jobs = 0
      )
    })
  })
})

test_that("basic hyperparameter tuning", {
  expect_no_error({
    df <- data.frame(
      ds = seq.Date(as.Date('2022-01-01'), as.Date('2022-12-31'), 'day'),
      y = pi*cos(1:365)+rnorm(365)
    )
    suppressMessages({
      tune_prophet(
        df,
        horizon = 30,
        units = 'days',
        args.list = list(
          changepoint.prior.scale = c(0.1, 0.5)
        ),
        n.jobs = 2
      )
    })
  })
})

test_that("hyperparameter tuning: no args", {
  expect_error({
    df <- data.frame(
      ds = seq.Date(as.Date('2022-01-01'), as.Date('2022-12-31'), 'day'),
      y = pi*cos(1:365)+rnorm(365)
    )
    suppressMessages({
      tune_prophet(
        df,
        horizon = 30,
        units = 'days',
        args.list = list()
      )
    })
  })
})

test_that("hyperparameter tuning: wrong args", {
  expect_error({
    df <- data.frame(
      ds = seq.Date(as.Date('2022-01-01'), as.Date('2022-12-31'), 'day'),
      y = pi*cos(1:365)+rnorm(365)
    )
    suppressMessages({
      tune_prophet(
        df,
        horizon = 30,
        units = 'days',
        args.list = list(
          growth = c('flat', 'linear')
        )
      )
    })
  })
})
