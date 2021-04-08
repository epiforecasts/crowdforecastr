
baseline_forecast <- function(baseline, 
                              filtered_observations, 
                              num_horizons, 
                              horizon_interval = 7) {
  if (baseline[1] %in% c("zero baseline", "zero-baseline")) {
    median <- rep(0, num_horizons)
    width <- rep(0, num_horizons)
  }
  if (baseline[1] %in% c("constant baseline", "constant-baseline")) {
    # for rt forecast specify width manually
    if (golem::get_golem_options("app_mode") == "rt") {
      indices <- seq(
        (nrow(filtered_observations) - (num_horizons - 1) * 7), 
        nrow(filtered_observations), 
        by = 7
      )
      median <- round(filtered_observations$value[indices], 3)
      width <- 0.01 * 1:num_horizons
    } else {
      # get last observed value for median 
      last_value <- filtered_observations$value[nrow(filtered_observations)]
      median <- rep(last_value, num_horizons)
      
      sigma <-  filtered_observations %>%
        dplyr::mutate(difference = c(NA, diff(log(pmax(value, 1))))) %>%
        dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
        dplyr::filter(target_end_date > max(target_end_date) - 4 * horizon_interval) %>%
        dplyr::pull(difference) %>%
        sd(na.rm = TRUE)
      width <- rep(sigma, num_horizons)
    }
  }
  
  return(list(median = median, 
              width = width))
}