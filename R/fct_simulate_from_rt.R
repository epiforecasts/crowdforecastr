#' Simulate cases from Rt forecast
#'
#' @param forecasts the crowdforecastr forecast reactive list
#' @return A data frame
#' @importFrom dplyr rowwise mutate group_by select full_join arrange filter ungroup
#' @importFrom tidyr unnest
#' @importFrom data.table data.table


simulate_cases_from_rt <- function(forecast, epinow2_fit, num_samples = 200) {
  selection_id <- forecast$selected_combination
  raw_forecast <- data.table::data.table(
    target_end_date = forecast$x, 
    distribution = forecast$distribution, 
    width = forecast$width[[selection_id]], 
    median = forecast$median[[selection_id]]
  )
  
  forecast_samples <- raw_forecast %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      value = draw_samples(median = median, width = width,
                           distribution = distribution,
                           num_samples = num_samples),
      sample = list(seq_len(length(value)))
    ) %>%
    tidyr::unnest(cols = c(sample, value)) %>%
    dplyr::ungroup()
  
  dates <- forecast$x
  date_range <- seq(min(as.Date(min(dates))),
                    max(as.Date(max(dates))), by = "days")
  # n_samples <- max(forecast_samples$sample)
  helper_data <- expand.grid(target_end_date = date_range,
                             sample = 1:max(forecast_samples$sample))
  
  crowd_rt <- forecast_samples %>%
    dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
    dplyr::full_join(helper_data, by = c("target_end_date", "sample")) %>%
    dplyr::arrange(sample, target_end_date) %>%
    dplyr::group_by(sample) %>%
    dplyr::mutate(no_predictions = ifelse(all(is.na(value)), TRUE, FALSE)) %>%
    dplyr::filter(!no_predictions) %>%
    dplyr::select(target_end_date, value, sample) %>%
    dplyr::mutate(value = zoo::na.approx(value), 
                  value = round(value, 3), 
                  date = as.Date(target_end_date), 
                  target = "cases", 
                  location = forecast$selected_combination) %>%
    dplyr::ungroup() %>%
    dplyr::select(date, value, target, location) %>%
    dplyr::arrange(date) %>%
    dplyr::group_by(date) %>%
    dplyr::mutate(sample = seq_along(value)) %>%
    dplyr::ungroup()
  
  root_dir <- golem::get_golem_options("path_epinow2_samples")
  
  submission_date <- golem::get_golem_options("submission_date")
  
  simulations <-simulate_crowd_cases(
    crowd_rt,
    model_dir = root_dir,
    target_date = submission_date, 
    epinow2_fit = epinow2_fit
  )
  
  # get summary of simulations for current region
  sim_data <- list()

  sim_data$truth_data <- forecasthubutils::make_weekly(
    simulations[[forecast$selected_combination]]$cases$observations,
    value_cols = "confirm",
    group_by = NULL)  
  
  samples <- simulations[[forecast$selected_combination]]$cases$samples %>%
    dplyr::filter(variable == "reported_cases", 
                  date >= as.Date(submission_date) - 4)
  
  weekly_samples <- forecasthubutils::make_weekly(samples, value_cols = "value",
                                                  group_by = "sample")
  
  sim_data$forecast <- weekly_samples[, .(median = median(value), 
                                       lower_98 = quantile(value, 0.01),
                                       lower_95 = quantile(value, 0.025),
                                       lower_90 = quantile(value, 0.05), 
                                       lower_50 = quantile(value, 0.25),
                                       lower_20 = quantile(value, 0.4),
                                       upper_20 = quantile(value, 0.6), 
                                       upper_50 = quantile(value, 0.75), 
                                       upper_90 = quantile(value, 0.95), 
                                       upper_95 = quantile(value, 0.975), 
                                       upper_98 = quantile(value, 0.99)), 
                                   by = "target_end_date"]
  
  return(sim_data)
}







draw_samples <- function(distribution, median, width, num_samples = 200) {
  if (distribution == "log-normal") {
    values <- exp(rnorm(
      num_samples, mean = log(as.numeric(median)), sd = as.numeric(width))
    )
  } else if (distribution == "normal") {
    values <- rnorm(
      num_samples, mean = (as.numeric(median)), sd = as.numeric(width)
    )
  } else if (distribution == "cubic-normal") {
    values <- (rnorm(
      num_samples, mean = (as.numeric(median) ^ (1 / 3)), sd = as.numeric(width)
    )) ^ 3
  } else if (distribution == "fifth-power-normal") {
    values <- (rnorm(
      num_samples, mean = (as.numeric(median) ^ (1 / 5)), sd = as.numeric(width)
    )) ^ 5
  } else if (distribution == "seventh-power-normal") {
    values <- (rnorm(
      num_samples, mean = (as.numeric(median) ^ (1 / 7)), sd = as.numeric(width)
    )) ^ 7
  }
  out <- list(sort(values))
  return(out)
}


load_epinow <- function(target_region, dir, date) {
  print("start loading")
  out <- list()
  path <- file.path(dir, target_region, date)
  out$summarised <- readRDS(file.path(path, "summarised_estimates.rds"))
  out$samples <- readRDS(file.path(path, "estimate_samples.rds"))
  out$fit <- readRDS(file.path(path, "model_fit.rds"))
  out$args <- readRDS(file.path(path, "model_args.rds"))
  out$observations <- readRDS(file.path(path, "reported_cases.rds"))
  print("loading finished")
  return(out)
}

# epinoe2_fit is an object as returned by load_epinow
simulate_crowd_cases <- function(crowd_rt, model_dir, target_date, epinow2_fit) {
  locs <- unique(crowd_rt$location)
  sims <- map(locs, function(loc) {
    dt <- data.table::as.data.table(crowd_rt)
    tars <- unique(dt$target)
    sims <- map(tars, function(tar) {
      message("Simulating: ", tar, " in ", loc)
      # get data for target region
      dt_tar <- data.table::as.data.table(dt)
      setDT(dt_tar)
      dt_tar <- dt_tar[, .(date, sample, value)]
      
      # extracted estimated Rt and cut to length of forecast
      est_R <- epinow2_fit$samples
      est_R <- est_R[sample <= max(dt_tar$sample)]
      est_R <- est_R[date < min(dt_tar$date)]
      
      # join estimates and forecast
      forecast_rt <- rbindlist(list(est_R, dt_tar))
      setorder(forecast_rt, sample, date)
      sims <- simulate_infections(estimates = epinow2_fit, forecast_rt, samples = max(forecast_rt$sample), 
                                  batch_size = 10)
      return(sims)
    })
    names(sims) <- tars
    return(sims)
  })
  names(sims) <- locs
  return(sims)
}
