# Launch the ShinyApp (Do not remove this comment)
# RT app
library(data.table)
library(dplyr)
library(crowdforecastr)
library(magrittr)
library(rstantools)
library(lubridate)
library(shinyjs)
library(EpiNow2)
library(purrr)
library(data.table)
library(ggplot2)
library(forecasthubutils)
library(shinybusy)

options("golem.app.prod" = TRUE)

# load submission date from data if on server
submission_date <- "2021-04-05"

first_forecast_date <- as.character(as.Date(submission_date) - 16)

# Run on local machine to load the latest data.
# Will be skipped on the shiny server
obs <- fread(
  paste0("../covid-german-forecasts/rt-forecast/data/summary/cases/", submission_date, "/rt.csv")
) %>%
  rename(value = median, target_end_date = date) %>%
  mutate(target_type = "case", target_end_date = as.Date(target_end_date)) %>%
  filter(target_end_date <= (as.Date(first_forecast_date) + 7 * 6)) %>%
  filter(region %in% c("Poland", "Germany")) %>%
  arrange(region, target_type, target_end_date)

run_app(
  data = obs,
  app_mode = "rt",
  selection_vars = c("region"),
  first_forecast_date = first_forecast_date,
  submission_date = submission_date,
  horizons = 7,
  horizon_interval = 7,
  path_service_account_json = "../covid-german-forecasts/crowd-forecast/.secrets/crowd-forecast-app-c98ca2164f6c-service-account-token.json",
  google_account_mail = "epiforecasts@gmail.com",
  force_increasing_uncertainty = FALSE,
  default_distribution = "normal",
  forecast_sheet_id = "1g4OBCcDGHn_li01R8xbZ4PFNKQmV-SHSXFlv2Qv79Ks",
  user_data_sheet_id = "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ",
  path_past_forecasts = "external_ressources/processed-forecast-data/"
)





# 
# 
# library(magrittr)
# library(dplyr)
# library(tidyr)
# library(zoo)
# 
# raw_forecast <- data.table::fread("../covid-german-forecasts/rt-crowd-forecast/raw-forecast-data/2021-02-22-raw-forecasts.csv") %>%
#   dplyr::filter(forecaster_id == "515822")
# 
# 
# 
# draw_samples <- function(distribution, median, width, num_samples = 50) {
#   if (distribution == "log-normal") {
#     values <- exp(rnorm(
#       num_samples, mean = log(as.numeric(median)), sd = as.numeric(width))
#     )
#   } else if (distribution == "normal") {
#     values <- rnorm(
#       num_samples, mean = (as.numeric(median)), sd = as.numeric(width)
#     )
#   } else if (distribution == "cubic-normal") {
#     values <- (rnorm(
#       num_samples, mean = (as.numeric(median) ^ (1 / 3)), sd = as.numeric(width)
#     )) ^ 3
#   } else if (distribution == "fifth-power-normal") {
#     values <- (rnorm(
#       num_samples, mean = (as.numeric(median) ^ (1 / 5)), sd = as.numeric(width)
#     )) ^ 5
#   } else if (distribution == "seventh-power-normal") {
#     values <- (rnorm(
#       num_samples, mean = (as.numeric(median) ^ (1 / 7)), sd = as.numeric(width)
#     )) ^ 7
#   }
#   out <- list(sort(values))
#   return(out)
# }
# 
# # draw samples
# forecast_samples <- raw_forecast %>%
#   rowwise() %>%
#   mutate(
#     value = draw_samples(median = median, width = width,
#                          distribution = distribution,
#                          num_samples = 50),
#     sample = list(seq_len(length(value)))
#   ) %>%
#   unnest(cols = c(sample, value)) %>%
#   ungroup()
# 
# 
# # interpolate missing days
# # I'm pretty sure the horizon time indexing is currently wrong.
# dates <- unique(forecast_samples$target_end_date)
# date_range <- seq(min(as.Date(min(dates))),
#                   max(as.Date(max(dates))), by = "days")
# submission_date <- unique(forecast_samples$submission_date)
# forecaster_ids <- unique(forecast_samples$forecaster_id)
# n_samples <- max(forecast_samples$sample)
# 
# # solve with a list
# helper_data <- expand.grid(target_end_date = date_range,
#                            forecaster_id = forecaster_ids,
#                            location = c("GM", "PL"),
#                            submission_date = submission_date,
#                            sample = 1:n_samples)
# 
# forecast_samples_daily <- forecast_samples %>%
#   mutate(target_end_date = as.Date(target_end_date)) %>%
#   full_join(helper_data) %>%
#   arrange(forecaster_id, location, sample, target_end_date) %>%
#   group_by(forecaster_id, location, sample) %>%
#   mutate(no_predictions = ifelse(all(is.na(value)), TRUE, FALSE)) %>%
#   filter(!no_predictions) %>%
#   mutate(value = na.approx(value))
# 
# 
# 
# 
# 
# 
# # Packages ----------------------------------------------------------------
# library(covid.german.forecasts)
# library(EpiNow2)
# library(data.table)
# library(here)
# library(purrr)
# library(ggplot2)
# library(lubridate)
# library(devtools)
# 
# 
# 
# 
# # parallel
# options(mc.cores = 4)
# # Set forecasting date ----------------------------------------------------
# target_date <- as.Date("2021-02-22")
# 
# # Get Rt forecasts --------------------------------------------------------
# crowd_rt <- as.data.table(forecast_samples_daily)
# 
# 
# # dropped redundant columns and get correct shape
# crowd_rt <- crowd_rt[, .(location,
#                          date = as.Date(target_end_date),
#                          value = round(value, 3)
# )]
# crowd_rt[location %in% "GM", location := "Germany"]
# crowd_rt[location %in% "PL", location := "Poland"]
# crowd_rt[, sample := 1:.N, by = .(location, date)]
# crowd_rt[, target := "cases"]
# 
# # Simulate cases ----------------------------------------------------------
# root_dir <- "../covid-german-forecasts/rt-crowd-forecast/data/rt-epinow-data"
# 
# simulations <- simulate_crowd_cases(
#   crowd_rt,
#   model_dir = root_dir,
#   target_date = target_date
# )
# 
# # Extract output ----------------------------------------------------------
# crowd_cases <- extract_samples(simulations, "cases")
# 
# # save output
# plot_dir <- here("rt-crowd-forecast", "data", "plots", target_date)
# check_dir(plot_dir)
# 
# walk(names(simulations), function(loc) {
#   walk(names(simulations[[1]]), function(tar) {
#     ggsave(paste0(loc, "-", tar, ".png"),
#            simulations[[loc]][[tar]]$plot,
#            path = plot_dir, height = 9, width = 9
#     )
#   })
# })
# 
# # Simulate deaths --------------------------------------------------------------
# observations <- get_observations(dir = "../covid-german-forecasts/data-raw", target_date,
#                                  locs = c("Germany", "Poland"))
# 
# # Forecast deaths from cases ----------------------------------------------
# source_gist("https://gist.github.com/seabbs/4dad3958ca8d83daca8f02b143d152e6")
# 
# # run across Poland and Germany specifying
# # options for estimate_secondary (EpiNow2)
# deaths_forecast <- regional_secondary(
#   observations, crowd_cases[, cases := value],
#   delays = delay_opts(list(
#     mean = 2.5, mean_sd = 0.5,
#     sd = 0.47, sd_sd = 0.2, max = 30
#   )),
#   return_fit = FALSE,
#   secondary = secondary_opts(type = "incidence"),
#   obs = obs_opts(scale = list(mean = 0.01, sd = 0.02)),
#   burn_in = as.integer(max(observations$date) - min(observations$date)) - 3 * 7,
#   control = list(adapt_delta = 0.98, max_treedepth = 15),
#   verbose = FALSE
# )
# 
# # Submission --------------------------------------------------------------
# # Cumulative data
# cum_cases <- fread(here("data-raw", "weekly-cumulative-cases.csv"))
# cum_deaths <- fread(here("data-raw", "weekly-cumulative-deaths.csv"))
# 
# crowd_cases <- format_forecast(crowd_cases,
#                                locations = locations,
#                                cumulative = cum_cases[location_name %in% c("Germany", "Poland")],
#                                forecast_date = target_date,
#                                submission_date = target_date,
#                                target_value = "case"
# )
# 
# crowd_deaths <- format_forecast(deaths_forecast$samples,
#                                 locations = locations,
#                                 cumulative = cum_deaths[location_name %in% c("Germany", "Poland")],
#                                 forecast_date = target_date,
#                                 submission_date = target_date,
#                                 target_value = "death"
# )
# 
# # save forecasts
# crowd_folder <- here("submissions", "crowd-rt-forecasts", target_date)
# check_dir(crowd_folder)
# 
# save_crowd_rt <- function(...) {
#   save_forecast(model = "-epiforecasts-EpiExpert_Rt", 
#                 folder = crowd_folder,
#                 date = target_date,
#                 ...)
# }
# save_crowd_rt(crowd_cases, "Germany", "GM", "-case")
# save_crowd_rt(crowd_cases, "Poland", "PL", "-case")
# save_crowd_rt(crowd_deaths, "Germany", "GM")
# save_crowd_rt(crowd_deaths, "Poland", "PL")
# 
