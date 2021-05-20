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
                    HTML("<h4><b>Data update</b>: Every Sunday at 12pm UK time (11am CET)</h4>"),
                    HTML("<h4><b>Submission deadline</b>: Every Monday at 8pm UK time (9pm CET)</h4>"),
                    br(),
                    HTML("<h4><b>Performance board</b>: <a href = 'https://epiforecasts.io/crowd-evaluation'>here</a></h4>"),
                    HTML("<h4><b>Forecast targets</b>: You can select the targets you want to forecasts under 'Account Details'</h4>"),
                    HTML("<h4><b>Zoom note</b>: If the app doesn't fit on your screen we highly recommend you zoom out a bit</h4>"),
                    HTML("<h4><b>Test account</b>: If you just want to take a look, log in with username and password 'test'</h4>")
                    )
             ),
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
                              pwd_col = Password,
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
