intialise_baseline_forecast <- function(observations, selection_vars) {
  # get all possible combinations for the selection_vars and turn them into
  # unique identifiers
  possible_selections <- list()
  for (selection_var in selection_vars) {
    possible_selections[[selection_var]] <- unique(observations[[selection_var]])
  }
  combinations <- expand.grid(possible_selections)
  selection_names <- apply(combinations, MARGIN = 1, 
                           FUN = function(x) {
                             paste(x, collapse = " - ")
                           })
  
  # initialise median and width to hold all baseline forecasts
  median <- list()
  width <- list()
  for (i in 1:length(selection_names)) {
    data <- observations
    for (selection_var in selection_vars) {
      data <- dplyr::filter(data, 
                            !!sym(selection_var) == combinations[[selection_var]][i])
    }
    baseline <- baseline_forecast(baseline = golem::get_golem_options("default_baseline"), 
                                  filtered_observations = data, 
                                  num_horizons = golem::get_golem_options("horizons"))
    median[[selection_names[i]]] <- baseline$median
    width[[selection_names[i]]] <- baseline$width
  }
  return(list(median = median, 
              width = width))
}
