filter_data_util <- function(data, view_options, selection_vars) {
  data <- data %>%
    dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
    dplyr::filter(target_end_date >= max(target_end_date) - view_options$weeks_to_show * 7)
  
  for (var in selection_vars) {
    data <- dplyr::filter(data, 
                          !!sym(var) == view_options[[var]])
  }
  
  return(data)
}

