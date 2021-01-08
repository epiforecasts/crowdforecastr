#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom googlesheets4 gs4_auth read_sheet
#' @importFrom googledrive drive_auth drive_token
#' @import shinyauthr
#' @import shinyalert
#' @noRd
app_server <- function( input, output, session ) {
  
  # manage google authentification
  options(gargle_oauth_cache = ".secrets")
  googledrive::drive_auth(cache = ".secrets", email = golem::get_golem_options("google_account_mail"))
  googlesheets4::gs4_auth(token = googledrive::drive_token())
  
  # reassign some values for simplicity that were given as inputs by the user
  data <- golem::get_golem_options("data")
  num_horizons <- golem::get_golem_options("horizons")
  forecast_quantiles <- golem::get_golem_options("forecast_quantiles")
  app_up_to_date <- golem::get_golem_options("app_up_to_date")
  forecast_sheet_id <- golem::get_golem_options("forecast_sheet_id")
  use_user_management <- golem::get_golem_options("user_management")
  observations <- golem::get_golem_options("data")
  
  user_management <- NULL
  
  if (use_user_management) {
    # load user data
    user_data_sheet_id <- golem::get_golem_options("user_data_sheet_id")
    user_data <- googlesheets4::read_sheet(ss = user_data_sheet_id)
    
    path_past_forecasts <- golem::get_golem_options("path_past_forecasts")
    
    # store everything needed for user management in a list
    user_management <- reactiveValues(
      user_data_sheet_id = user_data_sheet_id,
      current_user_data = NULL,
      open_login = TRUE,
      app_unlocked = FALSE, 
      open_new_user_consent = FALSE, 
      open_create_new_user = FALSE,
      consent_given = FALSE,
      open_create_user_form = FALSE
    )
    
    # open login screen when appropriate
    observeEvent(user_management$open_login, {
      
      if (user_management$open_login) {
        removeModal()
        showModal(modalDialog(
          tagList(
            mod_user_management_login_ui("login")
          ),
          footer = NULL, 
          size = "l"))
        # shinyalert::shinyalert(title = "Welcome", 
        #                        html = TRUE,
        #                        text = 
        #                          tagList(
        #                            mod_user_management_login_ui("login")
        #                          ), 
        #                        type = "", 
        #                        showConfirmButton = FALSE,
        #                        size = "l", 
        #                        immediate = TRUE)
      } 
    }, ignoreNULL = FALSE)
    mod_user_management_login_server("login", user_management, user_data)
    
    # open screen with consent needed to create new user if appropriate
    observeEvent(user_management$open_new_user_consent, {
      
      
      if (user_management$open_new_user_consent) {
        
        removeModal()
        showModal(modalDialog(
          tagList(
            mod_user_management_new_user_consent_ui("create_new_user_consent"),
          ), 
          footer = NULL, 
          size = "l"))
        
        # shinyalert::shinyalert(title = "Welcome", 
        #                        html = TRUE,
        #                        text = 
        #                          tagList(
        #                            
        #                            mod_user_management_new_user_consent_ui("create_new_user"),
        #                            h2("hello")
        #                            # mod_user_management_new_user_ui("new_user")
        #                          ), 
        #                        type = "", 
        #                        size = "l", 
        #                        immediate = TRUE)
      }
    })
    mod_user_management_new_user_consent_server("create_new_user_consent", 
                                                user_management)

    
    observeEvent(user_management$open_create_user_form, 
                 {
                   if (user_management$open_create_user_form) {
                     removeModal()
                     showModal(modalDialog(
                       size = "l",
                       title = "Create New User", 
                       mod_user_management_create_user_ui("create_user_form"),
                       footer = NULL
                     ))
                   }
                 })
    mod_user_management_create_user_server("create_user_form", 
                                           user_management)
    
    
    # if (!is.null(path_past_forecasts)) {
    #   user_management$past_forecasts <- load_past_forecasts(path_past_forecasts) %>%
    #     dplyr::filter(model == )
    #     
    # }
  }
  
  
  
  
  
  
  
  
  
  
  forecast <- reactiveValues(
    median = rep(NA, num_horizons),
    width = rep(NA, num_horizons),
    
    median_latent = rep(NA, num_horizons),
    width_latent = rep(NA, num_horizons),
    
    distribution = NA,

    x = max(as.Date(data$target_end_date)) + (1:num_horizons) * 7
  )
  view_options <- reactiveValues()
  
  baseline <- reactiveVal()
  

  mod_view_options_server("view_options", view_options = view_options,
                          forecast = forecast,
                          selection_vars = golem::get_golem_options("selection_vars"), 
                          observations = golem::get_golem_options("data"))
  mod_adjust_forecast_server("adjust_forecast", forecast = forecast, 
                             observations = observations, 
                             view_options = view_options, 
                             forecast_quantiles = forecast_quantiles,
                             selection_vars = golem::get_golem_options("selection_vars"),
                             num_horizons = num_horizons, 
                             baseline = baseline, 
                             user_management)
  
  mod_forecast_plot_server(id = "forecast_plot",
                           observations = golem::get_golem_options("data"),
                           forecast = forecast,
                           num_horizons = num_horizons,
                           selection_vars = golem::get_golem_options("selection_vars"),
                           view_options = view_options, 
                           forecast_quantiles = forecast_quantiles)
  
  mod_display_external_info_server("cfr", "https://ourworldindata.org/coronavirus-data-explorer?zoomToSelection=true&time=2020-03-14..latest&country=POL~DEU&region=World&cfrMetric=true&interval=total&aligned=true&hideControls=true&smoothing=0&pickerMetric=location&pickerSort=asc")

  mod_account_details_server("account_details", user_management)
  mod_past_performance_server("past_performance", user_management)
  
  
}
