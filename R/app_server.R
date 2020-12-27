#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # List the first level callModules here
  
  data <- golem::get_golem_options("data")
  num_horizons <- golem::get_golem_options("horizons")
  forecast_quantiles <- golem::get_golem_options("forecast_quantiles")
  
  current_data <- reactiveVal()
  
  # current_data  <- filter_data(data, ...)
  # do filtering within the individual server logic I guess?
  
  forecast <- reactiveValues(
    median = rep(NA, num_horizons),
    width = rep(NA, num_horizons),
    
    median_latent = rep(NA, num_horizons),
    width_latent = rep(NA, num_horizons),
    
    x = max(as.Date(data$target_end_date)) + (1:num_horizons) * 7
  )
  view_options <- reactiveValues()
  
  baseline <- reactiveVal()
  
  
  mod_plotly_test_server("test")

  mod_view_options_server("view_options", view_options = view_options,
                          selection_vars = golem::get_golem_options("selection_vars"), 
                          observations = golem::get_golem_options("data"))
  mod_forecast_plot_server(id = "forecast_plot",
                           observations = golem::get_golem_options("data"),
                           forecast = forecast,
                           num_horizons = num_horizons,
                           selection_vars = golem::get_golem_options("selection_vars"),
                           view_options = view_options, 
                           forecast_quantiles = forecast_quantiles)
  mod_adjust_forecast_server("adjust_forecast", forecast = forecast, 
                             observations = observations, 
                             view_options = view_options, 
                             forecast_quantiles = forecast_quantiles,
                             selection_vars = golem::get_golem_options("selection_vars"),
                             num_horizons = num_horizons, 
                             baseline = baseline)
  
  
  observe({print(event_data("plotly_relayout", source = "A"))})
  
  mod_display_external_info_server("cfr", "https://ourworldindata.org/coronavirus-data-explorer?zoomToSelection=true&time=2020-03-14..latest&country=POL~DEU&region=World&cfrMetric=true&interval=total&aligned=true&hideControls=true&smoothing=0&pickerMetric=location&pickerSort=asc")
  
  
}
