#' Simulate cases from Rt forecast
#'
#' @param forecasts the crowdforecastr forecast reactive list
#' @return A data frame
#' @importFrom dplyr rowwise mutate group_by select full_join arrange filter ungroup
#' @importFrom tidyr unnest
#' @importFrom data.table data.table


simulate_cases_from_rt <- function(forecast) {
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
                           num_samples = 50),
      sample = list(seq_len(length(value)))
    ) %>%
    tidyr::unnest(cols = c(sample, value)) %>%
    dplyr::ungroup()
  
  dates <- forecast$x
  date_range <- seq(min(as.Date(min(dates))),
                    max(as.Date(max(dates))), by = "days")
  # n_samples <- max(forecast_samples$sample)
  
  n_samples <- 50
  helper_data <- expand.grid(target_end_date = date_range,
                             sample = 1:n_samples)
  
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
                  location = forecast$selection_list$region) %>%
    dplyr::ungroup() %>%
    dplyr::select(date, value, target, location) %>%
    dplyr::arrange(date) %>%
    dplyr::group_by(date) %>%
    dplyr::mutate(sample = seq_along(value)) %>%
    dplyr::ungroup()
  
  root_dir <- "../covid-german-forecasts/rt-crowd-forecast/data/rt-epinow-data"
  
  submission_date <- golem::get_golem_options("submission_date")
  
  simulations <-simulate_crowd_cases(
    crowd_rt,
    model_dir = root_dir,
    target_date = submission_date
  )
  
  # get summary of simulations for current region
  sim_data <- list()

  sim_data$observations <- simulations[[forecast$selection_list$region]]$cases$observations
  sim_data$forecast <- simulations[[forecast$selection_list$region]]$cases$summarised %>%
    dplyr::filter(variable == "reported_cases", 
                  date >= as.Date(submission_date) - 4)
  
  return(sim_data)
}







draw_samples <- function(distribution, median, width, num_samples = 50) {
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
  out <- list()
  path <- file.path(dir, target_region, date)
  out$summarised <- readRDS(file.path(path, "summarised_estimates.rds"))
  out$samples <- readRDS(file.path(path, "estimate_samples.rds"))
  out$fit <- readRDS(file.path(path, "model_fit.rds"))
  out$args <- readRDS(file.path(path, "model_args.rds"))
  out$observations <- readRDS(file.path(path, "reported_cases.rds"))
  return(out)
}


simulate_crowd_cases <- function(crowd_rt, model_dir, target_date) {
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
      
      # load fit EpiNow2 model object
      model <- load_epinow(
        target_region = loc,
        dir = file.path(model_dir, tar),
        date = target_date
      )
      
      # extracted estimated Rt and cut to length of forecast
      est_R <- model$samples[variable == "R"]
      est_R <- est_R[, .(date = as.Date(date), sample, value)]
      est_R <- est_R[sample <= max(dt_tar$sample)]
      est_R <- est_R[date < min(dt_tar$date)]
      
      # join estimates and forecast
      forecast_rt <- rbindlist(list(est_R, dt_tar))
      setorder(forecast_rt, sample, date)
      
      sims <- simulate_infections(model, forecast_rt)
      sims$plot <- plot(sims)
      return(sims)
    })
    names(sims) <- tars
    return(sims)
  })
  names(sims) <- locs
  return(sims)
}






