


zero_baseline <- function(observations, 
                          num_horizons = 4, 
                          quantiles = c(0.5)) {
  
  median <- rep(0, num_horizons)
}



constant_baseline <- function(observations, 
                              num_horizons = 4, 
                              view_options, 
                              selection_vars,
                              quantiles = c(0.5)) {
  
  filtered <- filter_data_util(data = observations, 
                               view_options, 
                               selection_vars)
  
  last_value <- filtered$value[nrow(filtered)]
  
  median <- rep(last_value, num_horizons)
  
}
