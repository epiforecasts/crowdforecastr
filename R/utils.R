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
# this returns a list with one element for every element in selection_vars. 
# every element then contains a vector of all available possibilities based
# on the observations
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
# this gets the selection of forecast targets from the current_user_data. 
# if the user hasn't selected anything, every possibility is returned 
# based on the observations
get_selections <- function(current_user_data) {
  selection_vars <- golem::get_golem_options("selection_vars")
  observations <- golem::get_golem_options("data")
  
  selections <- list()
  for (var in selection_vars) {
    user_selection <- current_user_data[[paste0("selection_", var)]]
    
    # if nothing is selected, select everything
    if (is.null(user_selection) || is.na(user_selection)) {
      user_selection <- unique(observations[[var]])
    } else {
      user_selection <- strsplit(user_selection, split = ", ")[[1]]
    }
    
    selections[[var]] <- user_selection
  }
  return(selections)
}

# helper function to add a vertical line to a plotly plot
add_vline = function(p, x, ...) {
  l_shape = list(
    type = "line", 
    y0 = 0, y1 = 1, yref = "paper", # i.e. y as a proportion of visible region
    x0 = x, x1 = x, 
    line = list(...)
  )
  p %>% layout(shapes=list(l_shape))
}