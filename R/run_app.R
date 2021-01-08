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
  submission_date = NA,
  selection_vars = c("location", "target_type"),
  forecast_quantiles = c(0.01, 0.025, seq(0.05, 0.95, 0.05), 0.975, 0.99),
  google_account_mail = NULL, 
  forecast_sheet_id, 
  user_data_sheet_id,
  user_management = TRUE,
  path_past_forecasts = NULL,
  app_up_to_date = TRUE,
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
                        selection_vars = selection_vars, 
                        google_account_mail = google_account_mail, 
                        forecast_sheet_id = forecast_sheet_id, 
                        user_data_sheet_id = user_data_sheet_id, 
                        user_management = user_management,
                        submission_date = submission_date,
                        app_up_to_date = app_up_to_date), 
                   list(...))
  )
}



