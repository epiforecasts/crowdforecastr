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


# function to return a list of possible selections
list_selections <- function(selection_vars, observations) {
  possible_selections <- list()
  for (selection_var in selection_vars) {
    possible_selections[[selection_var]] <- unique(observations[[selection_var]])
  }
  return(possible_selections)
}

