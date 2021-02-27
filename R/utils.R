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
list_selections <- function() {
  selection_vars <- golem::get_golem_options("selection_vars")
  observations <- golem::get_golem_options("data")
  
  possible_selections <- list()
  for (selection_var in selection_vars) {
    possible_selections[[selection_var]] <- unique(observations[[selection_var]])
  }
  return(possible_selections)
}


# function to extract the selections from the user data
get_selections <- function(current_user_data) {
  selection_vars <- golem::get_golem_options("selection_vars")
  observations <- golem::get_golem_options("data")
  
  selections <- list()
  for (var in selection_vars) {
    user_selection <- current_user_data[[paste0("selection_", var)]]
    
    # if nothing is selected, select everything
    if (is.na(user_selection)) {
      user_selection <- unique(observations[[var]])
    } else {
      user_selection <- strsplit(user_selection, split = ", ")[[1]]
    }
    
    selections[[var]] <- user_selection
  }
  return(selections)
}