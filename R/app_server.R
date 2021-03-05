#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom googlesheets4 gs4_auth read_sheet
#' @importFrom googledrive drive_auth drive_token
#' @import shinyauthr
#' @importFrom shinyalert useShinyalert closeAlert
#' @importFrom attempt attempt is_try_error
#' @noRd
app_server <- function( input, output, session ) {
  
  # reassign some values for simplicity that were given as inputs by the user
  data <- golem::get_golem_options("data")
  num_horizons <- golem::get_golem_options("horizons")
  forecast_quantiles <- golem::get_golem_options("forecast_quantiles")
  app_up_to_date <- golem::get_golem_options("app_up_to_date")
  forecast_sheet_id <- golem::get_golem_options("forecast_sheet_id")
  use_user_management <- golem::get_golem_options("user_management")
  observations <- golem::get_golem_options("data")
  horizon_interval <- golem::get_golem_options("horizon_interval")
  first_forecast_date <- golem::get_golem_options("first_forecast_date")
  selection_vars <- golem::get_golem_options("selection_vars")
  
  possible_selections <- list_selections()
  
  # assign user_management so it can be passed around even if not used
  user_management <- NULL
  
  # if user management is used, define all necessary elements and server functions
  if (use_user_management) {
    # manage google authentification
    # if possible, use google service account token for authorisation
    if (!is.null(golem::get_golem_options("path_service_account_json"))) {
      path_json <- golem::get_golem_options("path_service_account_json")
      gs4_auth(path = path_json)
    } else {
      options(gargle_oauth_cache = ".secrets")
      googledrive::drive_auth(cache = ".secrets", email = golem::get_golem_options("google_account_mail"))
      googlesheets4::gs4_auth(token = googledrive::drive_token())
    }

    # load user data
    user_data_sheet_id <- golem::get_golem_options("user_data_sheet_id")
    user_data <- try_and_wait(
      googlesheets4::read_sheet(ss = user_data_sheet_id), 
      message = "We are trying to connect to the user data base."
    )
      
    # store everything needed for user management in a list
    user_management <- reactiveValues(
      user_data_sheet_id = user_data_sheet_id,
      selection_choice = NULL,
      current_user_data = NULL,
      user_data = user_data,
      open_login = TRUE,
      app_unlocked = FALSE, 
      open_new_user_consent = FALSE, 
      open_create_new_user = FALSE,
      consent_given = FALSE,
      open_create_user_form = FALSE
    )
    
    # server functions to handle the user management
    mod_user_management_server("user_management", 
                               user_management, 
                               user_data, 
                               user_data_sheet_id)
    
    # change the tab to the instructions tab if a new user is created
    observeEvent(user_management$open_create_user_form, 
                 {
                   if (user_management$open_create_user_form) {
                     updateTabItems(session, 
                                    inputId = "tabs", 
                                    selected = "instructions")
                   }
                 })
    
    
    past_forecasts <- golem::get_golem_options("past_forecasts")
    if (!is.null(past_forecasts)) {
      user_management$past_forecasts <- past_forecasts 
    }
  }
  
  baseline <- intialise_baseline_forecast(observations = observations, 
                                          possible_selections = possible_selections)

  forecast <- reactiveValues(
    # values that can be submitted
    median = baseline$median,
    width = baseline$width,
    # latent values that store changes in numeric input, without direct effect
    median_latent = baseline$median,
    width_latent = baseline$width,
    # chosen forecast distribution
    distribution = NA,
    # dates for which a forecast is made
    x = rep(NA, num_horizons),
    # store a list + string that keep track of which combination of
    # selection_vars is currently selected
    selection_list = list(),
    selected_combination = NULL
  )
  
  # set the forecast dates depending on the first forecast date
  if (first_forecast_date == "auto") {
    # go one time step beyond the last observed date for the first forecast date
    forecast$x <- max(as.Date(data$target_end_date)) + (1:num_horizons) * horizon_interval
  } else {
    forecast$x <- as.Date(first_forecast_date) + (0:(num_horizons - 1)) * horizon_interval
  }
  
  # store the currently selected view options. 
  view_options <- reactiveValues(
    desired_intervals = NULL, 
    weeks_to_show = NULL, 
    plot_scale = NULL
  )
  
  # add various server logic functions
  mod_view_options_server("view_options", view_options = view_options,
                          forecast = forecast,
                          selection_vars = selection_vars, 
                          observations = golem::get_golem_options("data"), 
                          user_management = user_management)
  

  
  mod_adjust_forecast_server("adjust_forecast", forecast = forecast, 
                             observations = observations, 
                             view_options = view_options, 
                             forecast_quantiles = forecast_quantiles,
                             selection_vars = selection_vars,
                             num_horizons = num_horizons, 
                             baseline = baseline, 
                             user_management)

  mod_forecast_plot_server(id = "forecast_plot",
                           observations = golem::get_golem_options("data"),
                           forecast = forecast,
                           num_horizons = num_horizons,
                           selection_vars = selection_vars,
                           view_options = view_options, 
                           forecast_quantiles = forecast_quantiles)
  mod_account_details_server("account_details", user_management)
  mod_past_performance_server("past_performance", user_management)
  
  # add server logic for additional information. Maybe that could be packed into one
  # user would then be able to decide how many of these to include, instead of them being hard coded here
  mod_display_external_info_server("our_world_in_data_dashboard", "https://ourworldindata.org/coronavirus-data-explorer?country=DEU~POL&region=World&casesMetric=true&interval=smoothed&smoothing=7&pickerMetric=location&pickerSort=asc")
  mod_display_external_info_server("cfr", "https://ourworldindata.org/coronavirus-data-explorer?zoomToSelection=true&time=2020-03-14..latest&country=POL~DEU&region=World&cfrMetric=true&interval=total&aligned=true&hideControls=true&smoothing=0&pickerMetric=location&pickerSort=asc")
  mod_display_external_info_server("positivity_rate", "https://ourworldindata.org/coronavirus-data-explorer?yScale=log&zoomToSelection=true&minPopulationFilter=1000000&time=earliest..latest&country=POL~DEU&region=World&casesMetric=true&interval=smoothed&aligned=true&hideControls=true&smoothing=7&pickerMetric=location&pickerSort=asc")
  mod_display_external_info_server("daily_testing", "https://ourworldindata.org/grapher/daily-tests-per-thousand-people-smoothed-7-day?tab=chart&stackMode=absolute&time=earliest..latest&country=DEU~POL&region=World")
  mod_display_external_info_server("gov_stringency", "https://ourworldindata.org/grapher/covid-stringency-index?tab=chart&stackMode=absolute&time=2020-01-22..latest&country=DEU~POL&region=Europe") 
  
}
