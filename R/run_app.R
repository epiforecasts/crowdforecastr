#' Run the Shiny Application
#' 
#' @param forecast_quantiles the quantiles for which a forecast shall be made
#' @param ... A series of options to be used inside the app.
#' 
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
  app_mode = c("regular", "rt"),
  app_title = "Crowd Forecast",
  data,
  first_forecast_date = "auto",
  horizons = 4,
  horizon_interval = 7,
  submission_date = NA,
  selection_vars = c("location", "target_type"),
  forecast_quantiles = c(0.01, 0.025, seq(0.05, 0.95, 0.05), 0.975, 0.99),
  google_account_mail = NULL, 
  path_service_account_json = NULL,
  forecast_sheet_id, 
  user_data_sheet_id,
  user_management = TRUE,
  path_epinow2_samples = "data-raw/samples",
  past_forecasts = NULL,
  app_up_to_date = TRUE,
  default_distribution = "log-normal",
  default_baseline = "constant baseline",
  force_increasing_uncertainty = TRUE,
  ...
) {
  with_golem_options(
    app = shinyApp(
      ui = app_ui, 
      server = app_server
    ), 
    golem_opts = c(list(app_title = app_title, 
                        app_mode = app_mode,
                        data = data, 
                        first_forecast_date = first_forecast_date,
                        horizons = horizons,
                        horizon_interval = horizon_interval,
                        forecast_quantiles = forecast_quantiles,
                        selection_vars = selection_vars, 
                        google_account_mail = google_account_mail, 
                        path_service_account_json = path_service_account_json,
                        forecast_sheet_id = forecast_sheet_id, 
                        user_data_sheet_id = user_data_sheet_id, 
                        user_management = user_management,
                        submission_date = submission_date,
                        app_up_to_date = app_up_to_date, 
                        path_epinow2_samples = path_epinow2_samples,
                        past_forecasts = past_forecasts, 
                        default_distribution = default_distribution, 
                        default_baseline = default_baseline,
                        force_increasing_uncertainty = force_increasing_uncertainty), 
                   list(...))
  )
}



