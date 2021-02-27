#' user_management_login UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_user_management_login_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    loginUI(id = ns("login")),
    br(), 
    fluidRow(column(12, 
                    style = 'padding-left: 15px; padding-right: 15px',
                    HTML("See the performance board <a href = 'https://epiforecasts.io/covid.german.forecasts'>here</a>"),
                    h4("Note: If the app doesn't fit on your screen we highly recommend you zoom out a bit"), 
                    h5("If you just want to take a look, log in with username and password 'test'"))),
    br(),
    actionButton(inputId = ns("new_user"),
                 label = "Create New User")
    
 
    
  )
}
    
#' user_management_login Server Functions
#'
#' @noRd 
mod_user_management_login_server <- function(id, 
                                             user_management, 
                                             user_data){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    credentials <- callModule(shinyauthr::login, "login", 
                              data = user_data,
                              user_col = username,
                              pwd_col = password,
                              sodium_hashed = TRUE,
                              log_out = reactive(TRUE))
    
    observeEvent(credentials()$user_auth, {
      if (credentials()$user_auth) {
        
        user_management$app_unlocked <- TRUE
        user_management$open_login <- FALSE
        
        user_management$current_user_data <- credentials()$info
        
        user_management$selection_choice <- get_selections(
          user_management$current_user_data
        )
        removeModal()
        
      }
    })
    
    observeEvent(input$new_user, {
      user_management$open_login <- FALSE
      user_management$open_new_user_consent <- TRUE
    })
    
 
  })
}
    
## To be copied in the UI
# mod_user_management_login_ui("user_management_login_ui_1")
    
## To be copied in the server
# mod_user_management_login_server("user_management_login_ui_1")
