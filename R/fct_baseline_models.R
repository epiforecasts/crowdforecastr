
baseline_forecast <- function(baseline, 
                              filtered_observations, 
                              num_horizons) {
  if (baseline == "zero baseline") {
    median <- rep(0, num_horizons)
    width <- rep(0, num_horizons)
  }
  if (baseline == "constant baseline") {
    # get last observed value for median 

    last_value <- filtered_observations$value[nrow(filtered_observations)]
    median <- rep(last_value, num_horizons)
    
    # get width
    sigma <-  filtered_observations %>%
      dplyr::mutate(difference = c(NA, diff(log(value)))) %>%
      dplyr::filter(target_end_date > max(target_end_date) - 4 * 7) %>%
      dplyr::pull(difference) %>%
      sd()
    width <- rep(sigma, num_horizons)
  }
  
  return(list(median = median, 
              width = width))
}

# 
# 
# 
# zero_baseline <- function(observations, 
#                           num_horizons,
#                           quantiles = c(0.5)) {
#   
#   # for (horizon in 1:num_horizons) {
#   #   forecast[[paste0("forecasts_horizon_", horizon)]]
#   # }
#   
#   median <- rep(0, num_horizons)
#   return(median)
# }



# 
# constant_baseline <- function(observations, 
#                               num_horizons, 
#                               view_options, 
#                               selection_vars,
#                               quantiles = c(0.5)) {
#   
# 
#   
# }
