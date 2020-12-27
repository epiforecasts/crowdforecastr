#' Run the Shiny Application
#' 
#' @param forecast_quantiles the quantiles for which a forecast shall be made
#' @param ... A series of options to be used inside the app.
#' 
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
  data,
  horizons = 4,
  selection_vars = c("location", "target_type"),
  forecast_quantiles = c(0.01, 0.025, seq(0.05, 0.95, 0.05), 0.975, 0.99),
  ...
) {
  with_golem_options(
    app = shinyApp(
      ui = app_ui, 
      server = app_server
    ), 
    golem_opts = c(list(data = data, 
                        horizons = horizons,
                        forecast_quantiles = forecast_quantiles,
                        selection_vars = selection_vars), 
                   list(...))
  )
}



