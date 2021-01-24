
baseline_forecast <- function(baseline, 
                              filtered_observations, 
                              num_horizons, 
                              horizon_interval = 7) {
  if (baseline[1] %in% c("zero baseline", "zero-baseline")) {
    median <- rep(0, num_horizons)
    width <- rep(0, num_horizons)
  }
  if (baseline[1] %in% c("constant baseline", "constant-baseline")) {
    # get last observed value for median 

    last_value <- filtered_observations$value[nrow(filtered_observations)]
    median <- rep(last_value, num_horizons)
    
    # get width
    sigma <-  filtered_observations %>%
      dplyr::mutate(difference = c(NA, diff(log(value)))) %>%
      dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
      dplyr::filter(target_end_date > max(target_end_date) - 4 * horizon_interval) %>%
      dplyr::pull(difference) %>%
      sd(na.rm = TRUE)
    width <- rep(sigma, num_horizons)
  }
  
  return(list(median = median, 
              width = width))
}